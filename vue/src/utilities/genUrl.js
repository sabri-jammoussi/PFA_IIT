import api from '@/services/api';

const LOG = '[imgGenUrl]';

let cloudinary_img_prefix;
let cloudinary_img_user_prefix;
let cloudinary_img_logo_prefix;
let cloudinary_img_background_prefix;

let upload_url;
let base_url;
let cloud_folder;

function randomString(length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}

const initialize = ({ imagesUrl, imagesUploadUrl, imagesPrefix, imagesLogoPrefix, imagesUserPrefix, imagesBackgroundPrefix, imagesFolder }) => {
    base_url = imagesUrl;
    upload_url = imagesUploadUrl;
    cloudinary_img_prefix = imagesPrefix;
    cloudinary_img_user_prefix = imagesUserPrefix;
    cloudinary_img_logo_prefix = imagesLogoPrefix;
    cloudinary_img_background_prefix = imagesBackgroundPrefix;
    cloud_folder = imagesFolder;
    console.log(LOG, 'initialized', { base_url, upload_url, cloud_folder });
};

// génerer URL de l'image
const genUrl = ({ type, id = undefined, v = undefined }) => {
    if (!id) {
        return '';
    }

    const imgId = generateId(type, id);
    if (!imgId) return '';

    var res = !v ? `${base_url}/${cloud_folder}/${imgId}` : `${base_url}/v${v}/${cloud_folder}/${imgId}`;
    return res;
};

// delete image
const deleteImg = async (public_id) => {
    console.log(LOG, 'delete image', { public_id });
    await api.delete('images', {
        params: { public_id },
    });
};

// upload image
const upload = async ({ file, type, id = '', appendRandomChar = false, isTransform = false }) => {
    const public_id = !appendRandomChar ? generateId(type, id) : `${generateId(type, id)}_${randomString(5)}`;

    console.log(LOG, 'uploading image', { public_id, type, isTransform });
    const { data } = await api.get('images/sign', { params: { public_id, isTransform } });
    console.log('uploading image signature', data);
    const formData = new FormData();
    formData.append('file', file);
    formData.append('api_key', data.publicKey);
    formData.append('public_id', data.publicId);
    formData.append('timestamp', data.timestamp);
    formData.append('signature', data.signature);
    formData.append('invalidate', true);
    if (!isTransform) {
        formData.append('transformation', data.transformation);
    }
    // Wait for upload response
    const uploadResponse = await fetch(upload_url, {
        method: 'POST',
        body: formData,
    });

    if (!uploadResponse.ok) {
        throw new Error(`Upload failed with status: ${uploadResponse.status}`);
    }

    // Get the actual response from Cloudinary
    const uploadResult = await uploadResponse.json();

    if (uploadResult.version) {
        try {
            await api.post('m/ImageVersion', {
                imageId: public_id,
                imageVersion: uploadResult.version,
                ImageId: public_id,
                ImageVersion: uploadResult.version
            });
        } catch (error) {
            console.error(LOG, 'Failed to save image version', error);
        }
    }
    return uploadResult.version;
};

const genLogoImageId = (id) => {
    return [`${cloudinary_img_prefix}_${cloudinary_img_logo_prefix}_${id}`.toLowerCase()].join('/');
};

const genBackgroundImageId = () => {
    return [`${cloudinary_img_prefix}_${cloudinary_img_background_prefix}`.toLowerCase()].join('/');
};

const genUserImageId = (id) => {
    return [`${cloudinary_img_prefix}_${cloudinary_img_user_prefix}_${id}`].join('/');
};

const generateId = (t, id) => {
    const result = {
        logo: genLogoImageId,
        background: genBackgroundImageId,
        user: genUserImageId,
    }[t];

    if (!result) {
        console.log(LOG, 'type undefined', { type: t });
        return '';
    }

    return result(id);
};

export { initialize, genUrl, upload, deleteImg, generateId };
