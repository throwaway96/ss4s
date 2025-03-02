#include "lgnc_common.h"

#include <string.h>

static SS4S_AudioOpenResult OpenAudio(const SS4S_AudioInfo *info, SS4S_AudioInstance **instance,
                                      SS4S_PlayerContext *context) {
    pthread_mutex_lock(&SS4S_LGNC_Lock);
    SS4S_AudioOpenResult result;
    switch (info->codec) {
        case SS4S_AUDIO_PCM_S16LE: {
            LGNC_ADEC_DATA_INFO_T pcmInfo = {
                    .codec = LGNC_ADEC_FMT_PCM,
                    .AChannel = LGNC_ADEC_CH_INDEX_MAIN,
                    .samplingFreq = LGNC_ADEC_SAMPLING_FREQ_OF(info->sampleRate),
                    .numberOfChannel = info->numOfChannels,
                    .bitPerSample = 16,
            };
            context->audioInfo = pcmInfo;
            break;
        }
        default:
            result = SS4S_AUDIO_OPEN_UNSUPPORTED_CODEC;
            goto finish;
    }
    if (LGNC_DIRECTAUDIO_Open(&context->audioInfo) != 0) {
        result = SS4S_AUDIO_OPEN_ERROR;
        goto finish;
    }
    context->audioOpened = true;
    *instance = (SS4S_AudioInstance *) context;
    result = SS4S_AUDIO_OPEN_OK;

    finish:
    pthread_mutex_unlock(&SS4S_LGNC_Lock);
    return result;
}

static SS4S_AudioFeedResult FeedAudio(SS4S_AudioInstance *instance, const unsigned char *data, size_t size) {
    SS4S_PlayerContext *context = (SS4S_PlayerContext *) instance;
    if (!context->audioOpened) {
        return SS4S_AUDIO_FEED_NOT_READY;
    }
    int rc = LGNC_DIRECTAUDIO_Play(data, size);
    if (rc != 0) {
        return SS4S_AUDIO_FEED_ERROR;
    }
    return SS4S_AUDIO_FEED_OK;
}

static void CloseAudio(SS4S_AudioInstance *instance) {
    pthread_mutex_lock(&SS4S_LGNC_Lock);
    SS4S_PlayerContext *context = (void *) instance;
    memset(&context->audioInfo, 0, sizeof(LGNC_ADEC_DATA_INFO_T));
    LGNC_DIRECTAUDIO_Close();
    pthread_mutex_unlock(&SS4S_LGNC_Lock);
}

const SS4S_AudioDriver SS4S_LGNC_AudioDriver = {
        .Base = {
                .Init = SS4S_LGNC_Driver_Init,
                .Quit = SS4S_LGNC_Driver_Quit,
        },
        .Open = OpenAudio,
        .Feed = FeedAudio,
        .Close = CloseAudio,
};