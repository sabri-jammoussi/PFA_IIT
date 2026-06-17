<template>
    <img v-show="!imageNotFound" v-if="imgUrl" :src="imgUrl" :key="imgKey" @load="onImageLoaded" @error="onImageError" />
</template>

<script>
import { ref, computed, watch, onMounted } from 'vue';
import { genUrl, generateId } from '@/utilities/genUrl';
import api from '@/services/api';

function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

// Track ongoing API requests to prevent duplicates
const pendingRequests = new Map();

export default {
    components: {},
    emits: ['loaded', 'error'],
    props: {
        id: {
            type: String,
        },
        type: {
            type: String,
            required: true,
        },
        refresh: {
            type: Number,
            default: 0,
        },
    },

    setup(props, context) {
        const componentId = getRandomInt(100000, 999999);
        const imageNotFound = ref(false);
        const loaded = ref(false);
        const version = ref();
        const imageName = generateId(props.type, props.id);

        const LOG = `[IMG-COMP|${componentId}|${imageName}]`;

        onMounted(async () => {
            await setImageVersion();
        });

        const setImageVersion = async () => {
            // Guard: if this imageName request is already pending, reuse it
            if (pendingRequests.has(imageName)) {
                version.value = await pendingRequests.get(imageName);
                if (!version.value) {
                    context.emit('error');
                }
                return;
            }

            // Create the request promise
            const requestPromise = (async () => {
                try {
                    const { data } = await api.get(`m/ImageVersion/${imageName}`);
                    version.value = data?.imageVersion;
                    if (!version.value) {
                        context.emit('error');
                    }
                    return data?.imageVersion;
                } catch (error) {
                    console.warn(LOG, 'Failed to fetch image version', error);
                    context.emit('error');
                    pendingRequests.delete(imageName); // Clear on error so retry is possible
                    return undefined;
                }
            })();

            // Store the pending request
            pendingRequests.set(imageName, requestPromise);

            // Wait for it and clean up
            await requestPromise;
            pendingRequests.delete(imageName);
        };

        const imgUrl = computed(() => {
            const v = version.value;
            const hasVersion = v !== undefined && v !== null && v !== 0;

            if (!hasVersion || imageNotFound.value) {
                return genUrl({ type: props.type });
            }
            return genUrl({ type: props.type, id: props.id, v });
        });

        const imgKey = computed(() => {
            return `${props.type}-${props.id}-${version.value || 'none'}-${props.refresh}`;
        });

        // Watch for manual refresh triggers
        watch(
            () => props.refresh,
            () => {
                imageNotFound.value = false;
                loaded.value = false;
                setImageVersion();
            }
        );

        watch(
            () => version.value,
            (newVal, oldVal) => {
                if (newVal !== oldVal) {
                    imageNotFound.value = false;
                    loaded.value = false;
                }
            }
        );

        const onImageLoaded = () => {
            loaded.value = true;
            context.emit('loaded');
        };

        const onImageError = () => {
            context.emit('error');
            imageNotFound.value = true;
            loaded.value = false;
        };

        return {
            onImageLoaded,
            onImageError,
            imgUrl,
            imgKey,
            loaded,
            imageNotFound,
        };
    },
};
</script>
