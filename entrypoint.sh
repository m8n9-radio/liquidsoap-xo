#!/bin/bash
set -e

# ========================================
# Default values (matching .env.dist)
# ========================================

# Icecast Server Configuration
export ICECAST_HOST=${ICECAST_HOST:-icecast}
export ICECAST_PORT=${ICECAST_PORT:-8000}
export ICECAST_PASSWORD=${ICECAST_PASSWORD:-hackme}
export ICECAST_MOUNT=${ICECAST_MOUNT:-stream}

# Radio Station Information
export RADIO_NAME=${RADIO_NAME:-Radio Dream}
export RADIO_DESCRIPTION=${RADIO_DESCRIPTION:-Radio Dream Stream}
export RADIO_GENRE=${RADIO_GENRE:-Various}
export RADIO_URL=${RADIO_URL:-http://localhost:8000}

# Harbor (Live Input) Configuration
export HARBOR_ENABLED=${HARBOR_ENABLED:-true}
export HARBOR_PORT=${HARBOR_PORT:-8001}
export HARBOR_PASSWORD=${HARBOR_PASSWORD:-hackme}
export HARBOR_USER=${HARBOR_USER:-source}

# Telnet Server Configuration
export TELNET_ENABLED=${TELNET_ENABLED:-true}
export TELNET_PORT=${TELNET_PORT:-1234}

# Logging Configuration
export LOG_LEVEL=${LOG_LEVEL:-4}

# Discogs API Configuration
export DISCOGS_ENABLED=${DISCOGS_ENABLED:-false}
export DISCOGS_TOKEN=${DISCOGS_TOKEN:-}
export DISCOGS_CACHE_MAX_SIZE=${DISCOGS_CACHE_MAX_SIZE:-10000}

# Telegram Notifications
export TELEGRAM_ENABLED=${TELEGRAM_ENABLED:-false}
export TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN:-}
export TELEGRAM_CHAT_ID=${TELEGRAM_CHAT_ID:-}

# Stream Encoding Configuration
export STREAM_FORMAT=${STREAM_FORMAT:-mp3}
export STREAM_BITRATE=${STREAM_BITRATE:-320}
export STREAM_SAMPLERATE=${STREAM_SAMPLERATE:-44100}

# Audio Configuration
export AUDIO_SAMPLERATE=${AUDIO_SAMPLERATE:-44100}
export AUDIO_CHANNELS=${AUDIO_CHANNELS:-2}

echo "========================================="
echo "Liquidsoap Radio - Starting..."
echo "========================================="

# Create necessary directories
echo "Creating directories..."
mkdir -p /app/storage/songs
mkdir -p /app/storage/jingles
mkdir -p /app/storage/playlists
mkdir -p /var/log/liquidsoap

# Generate songs playlist from storage
echo "Generating songs playlist..."
if [ -d "/app/storage/songs" ]; then
    SONG_COUNT=$(find /app/storage/songs -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.aac" -o -name "*.ogg" -o -name "*.m4a" \) 2>/dev/null | wc -l)

    if [ "$SONG_COUNT" -gt 0 ]; then
        find /app/storage/songs -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.aac" -o -name "*.ogg" -o -name "*.m4a" \) > /app/storage/playlists/songs.m3u
        echo "✓ Found $SONG_COUNT songs"
        echo "✓ Playlist saved to /app/storage/playlists/songs.m3u"
    else
        echo "⚠ WARNING: No audio files found in /app/storage/songs"
        echo "⚠ Creating empty playlist"
        touch /app/storage/playlists/songs.m3u
    fi
else
    echo "⚠ WARNING: /app/storage/songs directory not found"
    echo "⚠ Creating empty playlist"
    touch /app/storage/playlists/songs.m3u
fi

# Generate jingles playlist if directory exists
echo "Generating jingles playlist..."
if [ -d "/app/storage/jingles" ]; then
    JINGLE_COUNT=$(find /app/storage/jingles -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.aac" -o -name "*.ogg" -o -name "*.m4a" \) 2>/dev/null | wc -l)

    if [ "$JINGLE_COUNT" -gt 0 ]; then
        find /app/storage/jingles -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.aac" -o -name "*.ogg" -o -name "*.m4a" \) > /app/storage/playlists/jingles.m3u
        echo "✓ Found $JINGLE_COUNT jingles"
    else
        echo "ℹ No jingles found (optional)"
        touch /app/storage/playlists/jingles.m3u
    fi
else
    echo "ℹ Jingles directory not found (optional)"
    touch /app/storage/playlists/jingles.m3u
fi

# Display configuration
echo ""
echo "Configuration:"
echo "  Icecast Server: ${ICECAST_HOST}:${ICECAST_PORT}"
echo "  Mount Point: /${ICECAST_MOUNT}"
echo "  Stream Format: ${STREAM_FORMAT} @ ${STREAM_BITRATE} kbps / ${STREAM_SAMPLERATE} Hz"
echo "  Radio Name: ${RADIO_NAME}"
echo "  Genre: ${RADIO_GENRE}"
echo ""
echo "Features:"
echo "  Harbor (Live Input): ${HARBOR_ENABLED} (port ${HARBOR_PORT})"
echo "  Telnet Control: ${TELNET_ENABLED} (port ${TELNET_PORT})"
echo "  Discogs API: ${DISCOGS_ENABLED}"
echo "  Telegram Notifications: ${TELEGRAM_ENABLED}"
echo "  Log Level: ${LOG_LEVEL}"
echo ""

# Display playlist summary
echo "Playlist Summary:"
echo "  Songs: $(wc -l < /app/storage/playlists/songs.m3u) tracks"
echo "  Jingles: $(wc -l < /app/storage/playlists/jingles.m3u) tracks"
echo ""

echo "========================================="
echo "Starting Liquidsoap..."
echo "========================================="

# Execute liquidsoap with all arguments
exec liquidsoap "$@"
