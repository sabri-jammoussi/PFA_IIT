<template>
    <div class="img-user-wrapper" :style="{ width: computedSize, height: computedSize }">
        <div v-if="isLoading" class="spinner-overlay">
            <i class="pi pi-spin pi-spinner text-sky-500" style="font-size: 1.5rem;"></i>
        </div>
        
        <div :class="{ 'clickable': isImageOk(userId) }">
            <!-- Fallback avatar -->
            <div
                v-if="!isImageOk(userId) && !isLoading"
                class="img-user fallback-avatar flex items-center justify-center text-white font-bold uppercase shadow-sm"
                :style="{
                    backgroundColor: decimalToHex(avatarColeur) || '#4f46e5',
                    width: computedSize,
                    height: computedSize,
                    fontSize: computedFontSize,
                    borderRadius: '50%'
                }"
            >
                {{ shortNameUser || '??' }}
            </div>

            <ImageComponent 
                v-show="isImageOk(userId) || isLoading" 
                :id="String(userId)" 
                type="user" 
                class="img-user object-cover shadow-sm" 
                :style="{ width: computedSize, height: computedSize, borderRadius: '50%' }" 
                :refresh="internalRefresh" 
                @loaded="handleLoaded" 
                @error="handleError" 
            />
        </div>

        <!-- Edit camera overlay -->
        <template v-if="allowEdit && !isLoading">
            <label :for="'file-upload-' + userId" @click.stop>
                <span class="avatar-edit-btn">
                    <i class="pi pi-camera" />
                </span>
            </label>
            <input :id="'file-upload-' + userId" ref="fileInput" type="file" accept="image/*" class="hidden-input" @change="onFileChange" />
        </template>
    </div>
</template>

<script>
import { ref, computed, watch } from 'vue';
import ImageComponent from '@/components/ImageComponent.vue';
import { upload } from '@/utilities/genUrl';
import { toast } from 'vue3-toastify';
import { useAuthStore } from '@/stores/auth';

export default {
    components: { ImageComponent },
    emits: ['loaded', 'error', 'uploaded'],
    props: {
        userId: { type: Number, required: true },
        shortNameUser: { type: String },
        avatarColeur: { type: String },
        refreshPic: { type: Number, default: 0 },
        isConsultUserProfile: { type: Boolean },
        size: { type: String, default: null },
        allowEdit: { type: Boolean, default: false },
    },
    setup(props, context) {
        const imageStatus = ref({});
        const isLoading = ref(true);
        const internalRefresh = ref(props.refreshPic);
        const fileInput = ref(null);
        const authStore = useAuthStore();

        const computedSize = computed(() => {
            if (props.size) return props.size;
            return props.isConsultUserProfile ? '75px' : '38px';
        });

        const computedFontSize = computed(() => {
            const sizeValue = parseInt(computedSize.value) || 38;
            const baseSize = props.isConsultUserProfile ? 75 : 38;
            const baseFont = props.isConsultUserProfile ? 24 : 13;
            const fontSize = Math.floor((sizeValue * baseFont) / baseSize);
            return `${fontSize}px`;
        });

        const setImageStatus = (id, ok) => {
            imageStatus.value = { ...imageStatus.value, [id]: !!ok };
            isLoading.value = false;
        };

        const handleLoaded = () => {
            isLoading.value = false;
            setImageStatus(props.userId, true);
            context.emit('loaded');
        };

        const handleError = () => {
            isLoading.value = false;
            setImageStatus(props.userId, false);
            context.emit('error');
        };

        const isImageOk = (id) => imageStatus.value[id] === true;

        if (imageStatus.value[props.userId] == undefined) {
            isLoading.value = true;
        }

        const decimalToHex = (decimalColor) => {
            if (!decimalColor) return '#4F46E5';
            if (typeof decimalColor === 'string' && (decimalColor.startsWith('#') || decimalColor.length === 6 || decimalColor.length === 3)) {
                return decimalColor.startsWith('#') ? decimalColor : '#' + decimalColor;
            }
            try {
                const num = parseInt(decimalColor, 10);
                if (isNaN(num)) return '#4F46E5';
                return '#' + num.toString(16).toUpperCase().padStart(6, '0');
            } catch {
                return '#4F46E5';
            }
        };

        const onFileChange = async (event) => {
            try {
                const file = event.target.files?.[0];
                if (!file) return;

                if (!file.type.startsWith('image/')) {
                    toast.warning('Veuillez sélectionner un fichier image uniquement');
                    return;
                }

                if (file.size > 5 * 1024 * 1024) {
                    toast.warning('Image trop volumineuse (max 5MB)');
                    return;
                }

                isLoading.value = true;

                await upload({
                    file,
                    type: 'user',
                    id: props.userId,
                });

                if (props.userId === authStore.user?.id) {
                    authStore.incrementUserImageVersion();
                }

                internalRefresh.value++;
                isLoading.value = true;
                context.emit('uploaded');
                
                toast.success("Image de profil mise à jour avec succès");
            } catch (err) {
                console.error('[PROFILE-PIC] Upload failed:', err);
                toast.error("Erreur lors du téléchargement de l'image");
                isLoading.value = false;
            } finally {
                if (fileInput.value) {
                    fileInput.value.value = '';
                }
            }
        };

        watch(
            () => props.refreshPic,
            (newVal) => {
                internalRefresh.value = newVal;
                isLoading.value = true;
            }
        );

        return {
            imageStatus,
            isLoading,
            internalRefresh,
            fileInput,
            setImageStatus,
            isImageOk,
            decimalToHex,
            computedFontSize,
            computedSize,
            handleLoaded,
            handleError,
            onFileChange,
        };
    },
};
</script>

<style scoped>
.img-user-wrapper {
    position: relative;
    display: inline-block;
}
.img-user {
    object-fit: cover;
}
.spinner-overlay {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.65);
    z-index: 10;
}
.avatar-edit-btn {
    position: absolute;
    bottom: -4px;
    right: -4px;
    width: 28px;
    height: 28px;
    background: linear-gradient(135deg, #0ea5e9, #0284c7);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    box-shadow: 0 2px 6px rgba(14, 165, 233, 0.4);
    transition: all 0.2s ease;
    opacity: 0.95;
    z-index: 20;
    border: 2px solid #fff;
}

.avatar-edit-btn i {
    color: white;
    font-size: 12px;
}

.avatar-edit-btn:hover {
    transform: scale(1.1);
    box-shadow: 0 4px 10px rgba(14, 165, 233, 0.5);
    background: linear-gradient(135deg, #0284c7, #0369a1);
}

.hidden-input {
    display: none;
}

.clickable {
    cursor: pointer;
}
</style>
