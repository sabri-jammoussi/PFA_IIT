import * as signalR from '@microsoft/signalr';

class SignalRService {
    constructor() {
        this.connection = null;
    }

    startConnection() {
        if (this.connection && this.connection.state !== signalR.HubConnectionState.Disconnected) {
            return;
        }

        const token = localStorage.getItem('token');
        if (!token) return;

        this.connection = new signalR.HubConnectionBuilder()
            .withUrl(`http://localhost:5094/api/hubs/clinic`, {
                accessTokenFactory: () => token
            })
            .withAutomaticReconnect()
            .build();

        this.connection.start()
            .then(() => console.log('SignalR connected to ClinicHub'))
            .catch(err => console.error('SignalR connection error: ', err));
    }

    on(eventName, callback) {
        if (this.connection) {
            this.connection.on(eventName, callback);
        }
    }

    off(eventName, callback) {
        if (this.connection) {
            this.connection.off(eventName, callback);
        }
    }
}

export default new SignalRService();
