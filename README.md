# Liquidsoap Radio Streaming

Configurație Liquidsoap 2.3.3 pentru streaming radio cu suport StreamUrl pentru album covers.

## Caracteristici

- 🎵 **Playlist automat** - Songs + Jingles cu rotație configurabilă
- 🎙️ **Live streaming** - Harbor input pentru DJ-i (opțional)
- 🎨 **Album covers via StreamUrl** - Integrare Discogs API cu propagare în ICY metadata
- 🔄 **Auto-reload** - Playlist-uri monitorizate automat
- 🎚️ **Audio processing** - Normalize, compress, crossfade, blank skip
- 📡 **Multiple formate** - MP3, Vorbis, Opus
- 🔧 **Telnet control** - Control remote (opțional)

## StreamUrl pentru Album Covers

Liquidsoap caută album covers pe Discogs și le trimite ca `StreamUrl` în ICY metadata:

```
StreamTitle='Artist - Title';StreamUrl='https://i.discogs.com/.../cover.jpg';
```

### Cum funcționează

1. La fiecare track nou, extrage artist/title din metadata
2. Caută cover pe Discogs API (cu caching)
3. Trimite `url` către Icecast-KH cu `icy.update_metadata()`
4. Icecast-KH propagă ca `StreamUrl` în ICY metadata inline
5. Frontend-ul primește cover URL direct în stream

## Configurare

### 1. Copiază fișierul de configurare

```bash
cp .env.dist .env
```

### 2. Editează variabilele în `.env`

```bash
# Icecast Server
ICECAST_HOST=icecast
ICECAST_PORT=8000
ICECAST_PASSWORD=source_secret
ICECAST_MOUNT=stream

# Radio Station
RADIO_NAME=My Radio
RADIO_DESCRIPTION=Best Radio Ever
RADIO_GENRE=Various
RADIO_URL=http://myradio.com

# Stream Format
STREAM_FORMAT=mp3
STREAM_BITRATE=320
STREAM_SAMPLERATE=44100

# Discogs API (pentru album covers)
DISCOGS_ENABLED=true
DISCOGS_TOKEN=your_token_here
DISCOGS_CACHE_MAX_SIZE=10000

# Harbor (Live Input) - opțional
HARBOR_ENABLED=false
HARBOR_PORT=8001
HARBOR_PASSWORD=dj_password
HARBOR_USER=source

# Telnet Control - opțional
TELNET_ENABLED=true
TELNET_PORT=1234

# Logging (1-5)
LOG_LEVEL=4

# Telegram Notifications - opțional
TELEGRAM_ENABLED=false
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
```

### 3. Obține Discogs API Token

1. Creează cont pe [Discogs.com](https://www.discogs.com)
2. Settings → Developers → Generate Personal Access Token
3. Adaugă în `.env`: `DISCOGS_TOKEN=your_token`

## Rulare

### Docker Compose

```yaml
services:
  liquidsoap:
    build:
      context: apps/02-liquidsoap
    depends_on:
      - icecast
    volumes:
      - ./storage:/app/storage
    env_file:
      - apps/02-liquidsoap/.env
```

```bash
docker compose up -d liquidsoap
```

## Playlist-uri

### Structură

```
storage/
├── songs/           # Fișiere muzică
├── jingles/         # Jingles
└── playlists/
    ├── songs.m3u    # Playlist melodii
    └── jingles.m3u  # Playlist jingles
```

### Rotație

- 3 melodii → 1 jingle (configurabil în `stream.liq`)
- Crossfade 3 secunde între tracks
- Auto-reload când se modifică playlist-urile

## Formate Audio

| Format | Bitrate recomandat | Compatibilitate |
| ------ | ------------------ | --------------- |
| MP3    | 320 kbps           | Maximă          |
| Vorbis | 256 kbps           | Bună            |
| Opus   | 192 kbps           | Modernă         |

## Control Telnet

```bash
telnet localhost 1234
```

Comenzi:

- `help` - lista comenzi
- `radio.skip` - skip track
- `radio.metadata` - metadata curentă

## Verificare StreamUrl

```bash
# Vezi metadata în stream
curl -s -H "Icy-MetaData: 1" "http://localhost:8000/stream" --max-time 10 | strings | grep Stream
```

Output:

```
StreamTitle='Artist - Title';StreamUrl='https://i.discogs.com/.../cover.jpg';
```

## Troubleshooting

### StreamUrl nu apare

1. Verifică `DISCOGS_ENABLED=true` și token valid
2. Verifică log-uri: `docker compose logs liquidsoap | grep -i url`
3. Verifică că Icecast-KH primește url: `docker compose logs icecast | grep -i url`

### Cover nu se găsește

- Discogs caută după `artist + title`
- Verifică că fișierele au metadata ID3 corectă
- Activează Telegram notifications pentru alerte

### Playlist gol

```bash
# Regenerează playlist
find storage/songs -name "*.mp3" > storage/playlists/songs.m3u
```

## Structură Fișiere

```
02-liquidsoap/
├── Dockerfile         # Container Liquidsoap 2.3.3
├── stream.liq        # Configurație streaming
├── entrypoint.sh     # Script inițializare
├── .env              # Variabile mediu
├── .env.dist         # Exemplu variabile
└── README.md         # Documentație
```

## Resurse

- [Liquidsoap Documentation](https://www.liquidsoap.info/doc.html)
- [Discogs API](https://www.discogs.com/developers)
