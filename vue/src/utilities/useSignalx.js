import * as signalR from '@microsoft/signalr';
import { ref, computed, watch } from 'vue';
import { useAuthStore } from '@/stores/auth';

const connections = new Map();

const build = (hubName) => {
    const getAccessToken = () => {
        const authStore = useAuthStore();
        return authStore.token || localStorage.getItem('denti_token') || '';
    };

    const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:5094/api';
    const baseUrl = apiUrl.replace(/\/api\/?$/, '');
    const hubUrl = `${baseUrl}/hubs/${hubName}`;

    // Build SignalR connection with automatic reconnect
    const connection = new signalR.HubConnectionBuilder()
        .withUrl(hubUrl, {
            transport: signalR.HttpTransportType.WebSockets,
            skipNegotiation: false,
            withCredentials: true,
            logMessageContent: false,
            accessTokenFactory: getAccessToken,
        })
        .configureLogging(signalR.LogLevel.None)
        .withAutomaticReconnect()
        .withServerTimeout(60000)
        .withKeepAliveInterval(15000)
        .build();

    connections.set(hubName, connection);
    return connection;
};

export const waitForConnected = async (
    { connection, timeout, retries, checkInterval } = {
        timeout: 15000,
        retries: 100,
        checkInterval: 250,
    }
) => {
    timeout ??= 15000;
    retries ??= 100;
    checkInterval ??= 250;

    let timedout = false;
    let timeoutId = setTimeout(() => {
        timedout = true;
    }, timeout);

    try {
        let retriesCounter = 0;
        for (;;) {
            if (connection.state === signalR.HubConnectionState.Connected) {
                return { connected: true, connectionId: connection.connectionId };
            }

            if (timedout) {
                return { connected: false };
            }

            ++retriesCounter;
            if (retriesCounter > retries) {
                return { connected: false };
            }
            await new Promise((resolve) => setTimeout(resolve, checkInterval));
        }
    } finally {
        clearTimeout(timeoutId);
    }
};

export async function disconnect() {
    connections.forEach(async (connection, hubName) => {
        console.log(`[SignalR] Stopping connection for hub: ${hubName}`);
        await connection.stop();
    });

    connections.clear();
}

export default function (componentName, hubName) {
    hubName = hubName || 'notif';

    const _log = componentName ? `[SignalR] (${hubName}) ${componentName}` : `[SignalR] (${hubName})`;

    const connection = connections.get(hubName) ?? build(hubName);
    const state = ref(connection.state);
    const connected = computed(() => state.value === signalR.HubConnectionState.Connected);

    connection.onreconnecting(() => {
        console.log(`${_log} Connection reconnecting...`);
        state.value = connection.state;
    });

    connection.onreconnected(() => {
        console.log(`${_log} Connection reconnected.`);
        state.value = connection.state;
    });

    let reconnecting = false;

    connection.onclose(async (error) => {
        console.warn(`${_log} Connection closed.`, error);
        if (reconnecting) return;
        reconnecting = true;
        for (let attempt = 0; attempt < 10; attempt++) {
            const delay = Math.min(30000, 500 * Math.pow(2, attempt));
            
            await new Promise((r) => setTimeout(r, delay));

            const authStore = useAuthStore();
            if (!authStore.token) {
                console.warn(`${_log} Reconnect skipped (no token found).`);
                reconnecting = false;
                return;
            }

            try {
                await connection.start();
                console.info(`${_log} Reconnected successfully.`);
                reconnecting = false;
                return;
            } catch (err) {
                console.warn(`${_log} Reconnect attempt ${attempt + 1} failed`, err);
            }
        }
        reconnecting = false;
    });

    const authStore = useAuthStore();

    watch(
        () => authStore.token || localStorage.getItem('denti_token'),
        (newToken) => {
            if (newToken && connection.state === signalR.HubConnectionState.Disconnected) {
                console.log(`${_log} Token found, initiating connection...`);
                connection.start().then(
                    () => {
                        console.log(`${_log} Connection established successfully. ID:`, connection.connectionId);
                        state.value = connection.state;
                    },
                    (error) => {
                        console.error(`${_log} Connection failed:`, error);
                        state.value = connection.state;
                    }
                );
            } else if (!newToken && connection.state !== signalR.HubConnectionState.Disconnected) {
                connection.stop().then(() => {
                    console.log(`${_log} Connection stopped (no active token).`);
                    state.value = connection.state;
                });
            }
        },
        { immediate: true }
    );

    const wait = async () => {
        await waitForConnected({ connection });
        state.value = connection.state;
    };

    return {
        waitForConnected: wait,
        connected,
        connection,
        connectionState: state,
    };
}
