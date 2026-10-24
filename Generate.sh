mkdir -p shiny-radar && cd shiny-radar && cat > generate.sh <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
P=app/src/main/java/com/venice/shinycoords
mkdir -p "$P"/{domain/model,data/local,data/remote,location,service,ui/feed,ui/settings,ui/theme,util}
mkdir -p app/src/main/res/{values,values-night,drawable} .github/workflows
write() { mkdir -p "$(dirname "$1")"; cat > "$1"; }

write settings.gradle.kts <<'EOF'
pluginManagement {
    repositories { google(); mavenCentral(); gradlePluginPortal() }
}
dependencyResolutionManagement {
    repositories { google(); mavenCentral() }
}
rootProject.name = "ShinyRadar"
include(":app")
EOF

write build.gradle.kts <<'EOF'
plugins {
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.serialization") version "2.0.21" apply false
    id("com.google.devtools.ksp") version "2.0.21-1.0.28" apply false
}
EOF

write gradle.properties <<'EOF'
android.useAndroidX=true
org.gradle.jvmargs=-Xmx2048m
kotlin.code.style=official
EOF

write .gitignore <<'EOF'
.gradle/
build/
app/build/
local.properties
.idea/
*.iml
captures/
EOF

write app/proguard-rules.pro <<'EOF'
# leere Regeln, minify ist deaktiviert
EOF

write app/build.gradle.kts <<'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("org.jetbrains.kotlin.plugin.serialization")
    id("com.google.devtools.ksp")
}

android {
    namespace = "com.venice.shinycoords"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.venice.shinycoords"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }
    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
    buildFeatures { compose = true }
    packaging { resources.excludes += setOf("/META-INF/{AL2.0,LGPL2.1}") }
}

ksp { arg("room.schemaLocation", "$projectDir/schemas") }

dependencies {
    val bom = platform("androidx.compose:compose-bom:2024.09.02")
    implementation(bom)

    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.activity:activity-compose:1.9.2")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.6")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.6")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.6")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.7.3")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("androidx.datastore:datastore-preferences:1.1.1")
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    ksp("androidx.room:room-compiler:2.6.1")

    debugImplementation("androidx.compose.ui:ui-tooling")
}
EOF

write app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application
        android:name=".ShinyCoordsApp"
        android:allowBackup="true"
        android:icon="@drawable/ic_launcher"
        android:label="Shiny Radar"
        android:supportsRtl="true"
        android:theme="@style/Theme.ShinyRadar">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/Theme.ShinyRadar">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <service
            android:name=".service.SpawnTrackingService"
            android:exported="false"
            android:foregroundServiceType="dataSync" />

        <receiver
            android:name=".service.NotificationActionReceiver"
            android:exported="false" />
    </application>
</manifest>
EOF

write app/src/main/res/values/strings.xml <<'EOF'
<resources>
    <string name="app_name">Shiny Radar</string>
</resources>
EOF

write app/src/main/res/values/themes.xml <<'EOF'
<resources>
    <style name="Theme.ShinyRadar" parent="android:Theme.Material.NoActionBar">
        <item name="android:statusBarColor">#FF0E1116</item>
        <item name="android:windowBackground">#FF0E1116</item>
    </style>
</resources>
EOF

write app/src/main/res/values-night/themes.xml <<'EOF'
<resources>
    <style name="Theme.ShinyRadar" parent="android:Theme.Material.NoActionBar">
        <item name="android:statusBarColor">#FF0E1116</item>
        <item name="android:windowBackground">#FF0E1116</item>
    </style>
</resources>
EOF

write app/src/main/res/drawable/ic_launcher.xml <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#0E1116" android:pathData="M0,0h108v108h-108z" />
    <path android:fillColor="#4DD0C4"
        android:pathData="M54,16 L65,43 L94,46 L72,66 L79,95 L54,80 L29,95 L36,66 L14,46 L43,43 Z" />
</vector>
EOF

write app/src/main/res/drawable/ic_shiny_star.xml <<'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="#FFD54F"
        android:pathData="M12,2l2.9,6.26L22,9.27l-5,4.87L18.18,22L12,18.56L5.82,22L7,14.14l-5,-4.87l7.1,-1.01z" />
</vector>
EOF

write .github/workflows/build.yml <<'EOF'
name: Build ShinyRadar APK

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  apk:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: Gradle 8.9
        uses: gradle/actions/setup-gradle@v4
        with:
          gradle-version: '8.9'

      - name: Debug-APK bauen
        run: gradle assembleDebug --no-daemon

      - name: Release-APK bauen
        run: gradle assembleRelease --no-daemon

      - name: Sammeln
        run: |
          mkdir -p out
          cp app/build/outputs/apk/debug/app-debug.apk out/ShinyRadar-debug.apk
          cp app/build/outputs/apk/release/app-release-unsigned.apk out/ShinyRadar-release-unsigned.apk

      - name: Artifact
        uses: actions/upload-artifact@v4
        with:
          name: ShinyRadar-APK
          path: out/*.apk

      - name: Release mit Download-Link
        if: github.ref_type == 'tag' || github.event_name == 'workflow_dispatch'
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ github.ref_type == 'tag' && github.ref_name || format('build-{0}', github.run_number) }}
          name: ShinyRadar Build ${{ github.run_number }}
          files: out/*.apk
EOF

# ---------- Kotlin: Domäne ----------
write "$P/domain/model/ShinySpawn.kt" <<'EOF'
package com.venice.shinycoords.domain.model

import java.util.Locale

data class ShinySpawn(
    val id: String,
    val pokemonId: Int,
    val name: String,
    val lat: Double,
    val lng: Double,
    val iv: Int? = null,
    val cp: Int? = null,
    val level: Int? = null,
    val despawnAt: Long? = null,
    val country: String? = null,
    val city: String? = null,
    val shinyEligible: Boolean = true,
    val receivedAt: Long = System.currentTimeMillis(),
) {
    val coords: String
        get() = String.format(Locale.US, "%.5f, %.5f", lat, lng)

    val mapsUrl: String
        get() = "https://www.google.com/maps/search/?api=1&query=$lat,$lng"

    fun secondsUntilDespawn(now: Long = System.currentTimeMillis()): Long? =
        despawnAt?.let { ((it - now) / 1000L).coerceAtLeast(0) }
}

data class LatLng(val lat: Double, val lng: Double)
EOF

write "$P/domain/model/SpawnFilter.kt" <<'EOF'
package com.venice.shinycoords.domain.model

import com.venice.shinycoords.util.Geo

data class SpawnFilter(
    val minIv: Int = 0,
    val minCp: Int = 0,
    val maxDistanceKm: Int = 0,
    val onlyShinyEligible: Boolean = true,
    val rarityOnly: Boolean = false,
) {
    fun matches(spawn: ShinySpawn, user: LatLng?): Boolean {
        if (spawn.iv != null && spawn.iv < minIv) return false
        if (spawn.cp != null && spawn.cp < minCp) return false
        if (onlyShinyEligible && !spawn.shinyEligible) return false
        if (rarityOnly && spawn.name.lowercase() !in RARE_NAMES) return false
        if (maxDistanceKm > 0 && user != null) {
            if (Geo.distanceKm(user.lat, user.lng, spawn.lat, spawn.lng) > maxDistanceKm) return false
        }
        return true
    }

    companion object {
        val RARE_NAMES: Set<String> = setOf(
            "dratini", "dragonair", "larvitar", "pupitar", "beldum", "metang",
            "bagon", "shelgon", "gible", "gabite", "deino", "zweilous",
            "axew", "fraxure", "noibat", "noivern", "frigibax", "arctibax",
            "larvesta", "volcarona", "riolu", "lucario", "timburr", "rockruff",
            "jangmo-o", "hakamo-o", "dreepy", "drakloak", "tyrunt", "amaura",
            "aron", "trapinch", "swablu", "feebas", "clamperl", "shinx", "buizel",
            "cranidos", "shieldon", "happiny", "munchlax", "bonsly", "mime jr.",
        )
    }
}
EOF

# ---------- Kotlin: Utils ----------
write "$P/util/Geo.kt" <<'EOF'
package com.venice.shinycoords.util

import java.util.Locale
import kotlin.math.*

object Geo {
    private const val EARTH_R = 6371.0088

    fun distanceKm(lat1: Double, lng1: Double, lat2: Double, lng2: Double): Double {
        val dLat = Math.toRadians(lat2 - lat1)
        val dLng = Math.toRadians(lng2 - lng1)
        val a = sin(dLat / 2).pow(2) +
            cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) * sin(dLng / 2).pow(2)
        return 2 * EARTH_R * asin(min(1.0, sqrt(a)))
    }

    fun format(km: Double): String =
        if (km < 1) "${(km * 1000).roundToInt()} m"
        else String.format(Locale.US, "%.1f km", km)
}
EOF

write "$P/util/SpoofCooldown.kt" <<'EOF'
package com.venice.shinycoords.util

object SpoofCooldown {

    private val TABLE = listOf(
        1.0 to 30, 2.0 to 60, 5.0 to 120, 10.0 to 360, 25.0 to 660,
        30.0 to 840, 50.0 to 1320, 100.0 to 2580, 250.0 to 5280,
        500.0 to 6960, 750.0 to 8580, 1000.0 to 9780,
        1500.0 to 10800, 2000.0 to 11400, 2500.0 to 12000,
    )

    fun requiredSeconds(distanceKm: Double): Long {
        if (distanceKm <= 0.1) return 0
        TABLE.firstOrNull { distanceKm <= it.first }?.let { return it.second.toLong() }
        return 7200L
    }

    fun format(seconds: Long): String {
        val h = seconds / 3600
        val m = (seconds % 3600) / 60
        val s = seconds % 60
        return buildString {
            if (h > 0) append("${h}h ")
            if (m > 0 || h > 0) append("${m}min ")
            append("${s}s")
        }.trim()
    }
}
EOF

# ---------- Kotlin: Daten ----------
write "$P/data/SettingsStore.kt" <<'EOF'
package com.venice.shinycoords.data

import android.content.Context
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import com.venice.shinycoords.domain.model.SpawnFilter
import kotlinx.coroutines.flow.*

private val Context.dataStore by preferencesDataStore("shiny_radar_settings")

data class FeedConfig(
    val feedUrl: String,
    val pollSeconds: Int,
    val notify: Boolean,
    val minIv: Int,
    val authHeader: String = "",
    val failover: Boolean = true,
)

class SettingsStore(private val context: Context) {

    private object K {
        val FEED_URL = stringPreferencesKey("feed_url")
        val POLL = intPreferencesKey("poll_seconds")
        val NOTIFY = booleanPreferencesKey("notify")
        val MIN_IV = intPreferencesKey("min_iv")
        val MIN_CP = intPreferencesKey("min_cp")
        val MAX_DIST = intPreferencesKey("max_distance_km")
        val SHINY_ONLY = booleanPreferencesKey("only_shiny_eligible")
        val RARITY = booleanPreferencesKey("rarity_only")
        val AUTH = stringPreferencesKey("auth_header")
        val FAILOVER = booleanPreferencesKey("failover")
    }

    private val defaults: Map<Preferences.Key<*>, Any> = mapOf(
        K.FEED_URL to CANDIDATE_FEEDS.first(),
        K.POLL to 15,
        K.NOTIFY to true,
        K.MIN_IV to 0,
        K.MIN_CP to 0,
        K.MAX_DIST to 0,
        K.SHINY_ONLY to true,
        K.RARITY to false,
        K.AUTH to "",
        K.FAILOVER to true,
    )

    private fun <T> keyFlow(key: Preferences.Key<T>, fallback: T): Flow<T> =
        context.dataStore.data
            .catch { emit(emptyPreferences()) }
            .map { it[key] ?: fallback }

    private fun <T> keyFlow(key: Preferences.Key<T>): Flow<T> =
        keyFlow(key, defaults[key] as T)

    val filter: Flow<SpawnFilter> = combine(
        keyFlow(K.MIN_IV), keyFlow(K.MIN_CP), keyFlow(K.MAX_DIST),
        keyFlow(K.SHINY_ONLY), keyFlow(K.RARITY),
    ) { iv, cp, dist, shinyOnly, rarity ->
        SpawnFilter(iv, cp, dist, shinyOnly, rarity)
    }

    val config: Flow<FeedConfig> = combine(
        keyFlow(K.FEED_URL), keyFlow(K.POLL), keyFlow(K.NOTIFY),
        keyFlow(K.MIN_IV), keyFlow(K.AUTH),
    ) { url, poll, notify, iv, auth ->
        FeedConfig(url, poll, notify, iv, auth, true)
    }.combine(keyFlow(K.FAILOVER)) { cfg, fo -> cfg.copy(failover = fo) }

    suspend fun snapshot(): FeedConfig = config.first()

    suspend fun setFeedUrl(v: String) = context.dataStore.edit { it[K.FEED_URL] = v.trim() }
    suspend fun setPollSeconds(v: Int) = context.dataStore.edit { it[K.POLL] = v.coerceIn(5, 300) }
    suspend fun setNotify(v: Boolean) = context.dataStore.edit { it[K.NOTIFY] = v }
    suspend fun setMinIv(v: Int) = context.dataStore.edit { it[K.MIN_IV] = v }
    suspend fun setMinCp(v: Int) = context.dataStore.edit { it[K.MIN_CP] = v }
    suspend fun setMaxDistance(v: Int) = context.dataStore.edit { it[K.MAX_DIST] = v }
    suspend fun setShinyOnly(v: Boolean) = context.dataStore.edit { it[K.SHINY_ONLY] = v }
    suspend fun setRarityOnly(v: Boolean) = context.dataStore.edit { it[K.RARITY] = v }
    suspend fun setAuthHeader(v: String) = context.dataStore.edit { it[K.AUTH] = v.trim() }
    suspend fun setFailover(v: Boolean) = context.dataStore.edit { it[K.FAILOVER] = v }

    companion object {
        val CANDIDATE_FEEDS = listOf(
            "https://pokemongocoordinates.com/api/coordinates",
            "https://pokemongocoordinates.com/api/spawns",
            "https://pogocoordinates.com/api/coordinates",
            "https://gocoords.com/api/coordinates",
        )
    }
}
EOF

write "$P/data/local/SpawnEntity.kt" <<'EOF'
package com.venice.shinycoords.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.venice.shinycoords.domain.model.ShinySpawn

@Entity(tableName = "spawns")
data class SpawnEntity(
    @PrimaryKey val id: String,
    val pokemonId: Int,
    val name: String,
    val lat: Double,
    val lng: Double,
    val iv: Int?,
    val cp: Int?,
    val despawnAt: Long?,
    val country: String?,
    val city: String?,
    val receivedAt: Long,
)

fun ShinySpawn.toEntity() = SpawnEntity(
    id, pokemonId, name, lat, lng, iv, cp, despawnAt, country, city, receivedAt,
)
EOF

write "$P/data/local/SpawnDao.kt" <<'EOF'
package com.venice.shinycoords.data.local

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface SpawnDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(items: List<SpawnEntity>)

    @Query("SELECT * FROM spawns ORDER BY receivedAt DESC LIMIT 500")
    fun recent(): Flow<List<SpawnEntity>>

    @Query("DELETE FROM spawns WHERE receivedAt < :before")
    suspend fun prune(before: Long)

    @Query("DELETE FROM spawns")
    suspend fun clear()
}
EOF

write "$P/data/local/AppDatabase.kt" <<'EOF'
package com.venice.shinycoords.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(entities = [SpawnEntity::class], version = 1, exportSchema = true)
abstract class AppDatabase : RoomDatabase() {
    abstract fun spawnDao(): SpawnDao

    companion object {
        @Volatile private var instance: AppDatabase? = null
        fun get(ctx: Context): AppDatabase = instance ?: synchronized(this) {
            instance ?: Room.databaseBuilder(ctx.applicationContext, AppDatabase::class.java, "shiny_radar.db")
                .fallbackToDestructiveMigration()
                .build().also { instance = it }
        }
    }
}
EOF

write "$P/data/remote/PokemonNames.kt" <<'EOF'
package com.venice.shinycoords.data.remote

object PokemonNames {
    private val MAP = mapOf(
        1 to "Bulbasaur", 4 to "Charmander", 7 to "Squirtle", 25 to "Pikachu",
        39 to "Jigglypuff", 52 to "Meowth", 58 to "Growlithe", 63 to "Abra",
        66 to "Machop", 74 to "Geodude", 77 to "Ponyta", 92 to "Gastly",
        95 to "Onix", 98 to "Krabby", 116 to "Horsea", 129 to "Magikarp",
        131 to "Lapras", 133 to "Eevee", 137 to "Porygon", 143 to "Snorlax",
        147 to "Dratini", 152 to "Chikorita", 155 to "Cyndaquil", 158 to "Totodile",
        175 to "Togepi", 179 to "Mareep", 187 to "Hoppip", 194 to "Wooper",
        202 to "Wobbuffet", 215 to "Sneasel", 220 to "Swinub", 227 to "Skarmory",
        246 to "Larvitar", 252 to "Treecko", 255 to "Torchic", 258 to "Mudkip",
        263 to "Zigzagoon", 280 to "Ralts", 287 to "Slakoth", 302 to "Sableye",
        303 to "Mawile", 318 to "Carvanha", 347 to "Anorith", 349 to "Feebas",
        359 to "Absol", 371 to "Bagon", 374 to "Beldum", 380 to "Latias",
        381 to "Latios", 384 to "Rayquaza", 387 to "Turtwig", 390 to "Chimchar",
        393 to "Piplup", 403 to "Shinx", 443 to "Gible", 447 to "Riolu",
        448 to "Lucario", 479 to "Rotom", 495 to "Snivy", 498 to "Tepig",
        501 to "Oshawott", 532 to "Timburr", 559 to "Scraggy", 570 to "Zorua",
        572 to "Minccino", 577 to "Solosis", 607 to "Litwick", 621 to "Druddigon",
        633 to "Deino", 636 to "Larvesta", 643 to "Reshiram", 644 to "Zekrom",
        650 to "Chespin", 653 to "Fennekin", 656 to "Froakie", 674 to "Pancham",
        686 to "Inkay", 696 to "Tyrunt", 698 to "Amaura", 704 to "Goomy",
        714 to "Noibat", 722 to "Rowlet", 725 to "Litten", 728 to "Popplio",
        744 to "Rockruff", 747 to "Mareanie", 757 to "Salandit", 776 to "Turtonator",
        780 to "Drampa", 782 to "Jangmo-o", 810 to "Grookey", 813 to "Scorbunny",
        816 to "Sobble", 819 to "Skwovet", 821 to "Rookidee", 848 to "Toxel",
        868 to "Milcery", 885 to "Dreepy", 906 to "Sprigatito", 909 to "Fuecoco",
        912 to "Quaxly", 921 to "Pawmi", 996 to "Frigibax",
    )

    private val LOWER by lazy {
        MAP.entries.map { it.value.lowercase() to it.value }
            .sortedByDescending { it.first.length }
    }

    fun byId(id: Int): String? = MAP[id]
    fun findIn(text: String): String? {
        val t = text.lowercase()
        return LOWER.firstOrNull { t.contains(it.first) }?.second
    }
    fun idOf(name: String): Int? =
        MAP.entries.firstOrNull { it.value.equals(name, ignoreCase = true) }?.key
}
EOF

write "$P/data/remote/SpawnFeedParser.kt" <<'EOF'
package com.venice.shinycoords.data.remote

import com.venice.shinycoords.domain.model.ShinySpawn
import kotlinx.serialization.json.*
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter

object SpawnFeedParser {

    private val LAT = listOf("latitude", "lat", "y")
    private val LNG = listOf("longitude", "lng", "lon", "x")
    private val DEX = listOf("pokemon_id", "pokemonId", "dex", "dex_id", "id_pokemon", "pkmn_id")
    private val NAME = listOf("pokemon_name", "name", "species", "pokemon")
    private val IV = listOf("iv", "iv_percent", "iv_avg", "ivValue")
    private val CP = listOf("cp", "cp_value")
    private val LVL = listOf("level", "lvl", "pokemon_level")
    private val DESPAWN = listOf(
        "despawn_time", "despawn", "expire_timestamp", "disappear_time",
        "despawnAt", "expires_at", "expire_at", "until",
    )
    private val CITY = listOf("city", "town", "ort")
    private val COUNTRY = listOf("country", "land", "cc")

    private val COORD = Regex("""(-?\d{1,3}\.\d{3,8})\s*,\s*(-?\d{1,3}\.\d{3,8})""")
    private val IV_RX = Regex("""(\d{1,3})\s*(?:%|IV)""")
    private val CP_RX = Regex("""CP\s*(\d{1,4})""", RegexOption.IGNORE_CASE)
    private val LVL_RX = Regex("""L\s?(\d{1,2})\b""")
    private val DEX_RX = Regex("""#(\d{1,4})\b|No\.?\s*(\d{1,4})""")

    fun parse(raw: String, json: Json): List<ShinySpawn> {
        val root = runCatching { json.parseToJsonElement(raw) }.getOrNull() ?: return emptyList()
        val array = findArray(root) ?: return emptyList()
        val now = System.currentTimeMillis()
        return array.mapNotNull { parseOne(it, now) }
    }

    private fun findArray(el: JsonElement): JsonArray? = when (el) {
        is JsonArray -> el
        is JsonObject -> {
            val wrappers = listOf(
                "data", "results", "spawns", "pokemon", "list", "items",
                "features", "entries", "coordinates", "payload",
            )
            wrappers.firstNotNullOfOrNull { key -> el[key]?.let { findArray(it) } }
        }
        else -> null
    }

    private fun parseOne(el: JsonElement, now: Long): ShinySpawn? {
        val base = el as? JsonObject ?: return null
        val obj = (base["message"] as? JsonObject) ?: base

        if (obj.containsKey("content")) return parseDiscordMessage(obj, now)

        val geo = (obj["geometry"] as? JsonObject)?.get("coordinates") as? JsonArray
        val props = (obj["properties"] as? JsonObject) ?: obj

        val lat = geo?.getOrNull(1)?.jsonDoubleOrNull() ?: readDouble(props, LAT)
        val lng = geo?.getOrNull(0)?.jsonDoubleOrNull() ?: readDouble(props, LNG)
        if (lat == null || lng == null) return null
        if (lat !in -90.0..90.0 || lng !in -180.0..180.0) return null

        val dex = readInt(props, DEX) ?: 0
        val name = readString(props, NAME)?.takeIf { it.isNotBlank() }
            ?: PokemonNames.byId(dex)
            ?: return null

        val despawn = readString(props, DESPAWN)?.let { parseTime(it) }
        val ivRaw = readDouble(props, IV)?.let {
            if (it <= 1.0 && it > 0.0) (it * 100).toInt() else it.toInt()
        }?.coerceIn(0, 100)

        return ShinySpawn(
            id = props["encounter_id"]?.jsonPrimitive?.contentOrNull?.takeIf { it.isNotBlank() }
                ?: "$dex:$lat:$lng:$despawn",
            pokemonId = dex,
            name = name.replaceFirstChar { it.uppercase() },
            lat = lat,
            lng = lng,
            iv = ivRaw,
            cp = readInt(props, CP),
            level = readInt(props, LVL),
            despawnAt = despawn,
            country = readString(props, COUNTRY),
            city = readString(props, CITY),
            receivedAt = now,
        )
    }

    private fun parseDiscordMessage(obj: JsonObject, now: Long): ShinySpawn? {
        val content = obj["content"]?.jsonPrimitive?.contentOrNull ?: return null
        val m = COORD.find(content) ?: return null
        val lat = m.groupValues[1].toDoubleOrNull() ?: return null
        val lng = m.groupValues[2].toDoubleOrNull() ?: return null
        if (lat !in -90.0..90.0 || lng !in -180.0..180.0) return null

        val dex = DEX_RX.find(content)?.groupValues
            ?.drop(1)?.firstOrNull { it.isNotBlank() }?.toIntOrNull() ?: 0
        val name = PokemonNames.findIn(content) ?: PokemonNames.byId(dex) ?: return null

        return ShinySpawn(
            id = obj["id"]?.jsonPrimitive?.contentOrNull ?: "$name:$lat:$lng",
            pokemonId = dex.takeIf { it > 0 } ?: PokemonNames.idOf(name) ?: 0,
            name = name,
            lat = lat,
            lng = lng,
            iv = IV_RX.find(content)?.groupValues?.get(1)?.toIntOrNull()?.coerceIn(0, 100),
            cp = CP_RX.find(content)?.groupValues?.get(1)?.toIntOrNull(),
            level = LVL_RX.find(content)?.groupValues?.get(1)?.toIntOrNull(),
            receivedAt = now,
        )
    }

    private fun readString(o: JsonObject, keys: List<String>): String? =
        keys.firstNotNullOfOrNull { k ->
            o[k]?.jsonPrimitive?.contentOrNull?.takeIf { it.isNotBlank() }
        }

    private fun readDouble(o: JsonObject, keys: List<String>): Double? =
        keys.firstNotNullOfOrNull { k -> o[k]?.jsonPrimitive?.contentOrNull?.toDoubleOrNull() }

    private fun readInt(o: JsonObject, keys: List<String>): Int? = readDouble(o, keys)?.toInt()

    private fun parseTime(v: String): Long? {
        v.toLongOrNull()?.let { return if (it < 10_000_000_000L) it * 1000 else it }
        runCatching { return Instant.parse(v).toEpochMilli() }
        listOf("yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss").forEach { pattern ->
            runCatching {
                return LocalDateTime.parse(v, DateTimeFormatter.ofPattern(pattern))
                    .toInstant(ZoneOffset.UTC).toEpochMilli()
            }
        }
        return null
    }
}
EOF

write "$P/data/remote/ShinyCatalog.kt" <<'EOF'
package com.venice.shinycoords.data.remote

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import okhttp3.OkHttpClient
import okhttp3.Request

class ShinyCatalog(private val client: OkHttpClient, private val json: Json) {

    private val url = "https://pogoapi.net/api/v1/shiny_pokemon.json"
    private val mutex = Mutex()

    @Volatile private var ids: Set<Int>? = null
    @Volatile private var loadedAt: Long = 0L

    suspend fun eligibleIds(): Set<Int> = withContext(Dispatchers.IO) {
        mutex.withLock {
            val fresh = System.currentTimeMillis() - loadedAt < 24 * 3600_000L
            ids?.takeIf { fresh }?.let { return@withLock it }

            val fetched = runCatching {
                client.newCall(Request.Builder().url(url).build()).execute().use { resp ->
                    if (!resp.isSuccessful) return@use null
                    val body = resp.body?.string() ?: return@use null
                    val root = json.parseToJsonElement(body) as? JsonObject ?: return@use null
                    root.keys.mapNotNull { it.toIntOrNull() }.toSet()
                }
            }.getOrNull()

            if (fetched != null) { ids = fetched; loadedAt = System.currentTimeMillis() }
            ids ?: emptySet()
        }
    }

    suspend fun annotate(spawns: List<com.venice.shinycoords.domain.model.ShinySpawn>) =
        withContext(Dispatchers.Default) {
            val catalog = eligibleIds()
            if (catalog.isEmpty()) return@withContext spawns
            spawns.map { s -> s.copy(shinyEligible = s.pokemonId in catalog) }
        }
}
EOF

write "$P/data/SpawnRepository.kt" <<'EOF'
package com.venice.shinycoords.data

import com.venice.shinycoords.data.local.SpawnDao
import com.venice.shinycoords.data.local.toEntity
import com.venice.shinycoords.data.remote.ShinyCatalog
import com.venice.shinycoords.data.remote.SpawnFeedParser
import com.venice.shinycoords.domain.model.ShinySpawn
import com.venice.shinycoords.location.UserLocationProvider
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import okhttp3.Request

class SpawnRepository(
    private val client: OkHttpClient,
    private val json: Json,
    private val settings: SettingsStore,
    private val dao: SpawnDao,
    private val catalog: ShinyCatalog,
    private val location: UserLocationProvider,
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private var pollJob: Job? = null

    private val _all = MutableStateFlow<List<ShinySpawn>>(emptyList())
    private val _events = MutableSharedFlow<ShinySpawn>(extraBufferCapacity = 512)
    val events: SharedFlow<ShinySpawn> = _events.asSharedFlow()

    private val _status = MutableStateFlow("bereit")
    val status: StateFlow<String> = _status.asStateFlow()

    private val seen = object : LinkedHashMap<String, Long>(1024, 0.75f, true) {
        override fun removeEldestEntry(eldest: MutableMap.MutableEntry<String, Long>) = size > 5000
    }

    val spawns: StateFlow<List<ShinySpawn>> = combine(
        _all, settings.filter, location.location,
    ) { all, filter, loc -> all.filter { filter.matches(it, loc) } }
        .stateIn(scope, SharingStarted.Eagerly, emptyList())

    val history = dao.recent()

    fun start() {
        if (pollJob?.isActive == true) return
        pollJob = scope.launch {
            while (isActive) {
                val cfg = settings.snapshot()
                if (cfg.feedUrl.isBlank()) {
                    _status.value = "Keine Feed-URL gesetzt"
                } else {
                    val hit = runCatching { fetchFirstUsable(cfg) }.getOrNull()
                    if (hit == null) {
                        _status.value = "Keine Quelle lieferte Daten"
                    } else {
                        val (usedUrl, parsed) = hit
                        val annotated = catalog.annotate(parsed)
                        val fresh = ingest(annotated)
                        val host = usedUrl.substringAfter("//").substringBefore("/")
                        _status.value = "OK via $host – ${parsed.size} Einträge, ${fresh.size} neu"
                        fresh.forEach { _events.tryEmit(it) }
                    }
                }
                prune()
                delay(cfg.pollSeconds.coerceIn(5, 300) * 1000L)
            }
        }
    }

    fun stop() { pollJob?.cancel(); pollJob = null }
    fun restart() { stop(); start() }

    private fun fetch(url: String, auth: String = ""): String {
        val b = Request.Builder()
            .url(url)
            .header("Accept", "application/json")
            .header("User-Agent", "ShinyRadar/1.0 (Android)")
        if (auth.isNotBlank()) b.header("Authorization", auth)
        client.newCall(b.build()).execute().use { resp ->
            if (!resp.isSuccessful) error("HTTP ${resp.code}")
            return resp.body?.string().orEmpty()
        }
    }

    private fun fetchFirstUsable(cfg: FeedConfig): Pair<String, List<ShinySpawn>>? {
        val urls = buildList {
            add(cfg.feedUrl)
            if (cfg.failover) addAll(SettingsStore.CANDIDATE_FEEDS.filter { it != cfg.feedUrl })
        }
        urls.forEach { url ->
            runCatching { fetch(url, cfg.authHeader) }.onSuccess { body ->
                val parsed = SpawnFeedParser.parse(body, json)
                if (parsed.isNotEmpty()) return url to parsed
            }
        }
        return null
    }

    private suspend fun ingest(batch: List<ShinySpawn>): List<ShinySpawn> {
        if (batch.isEmpty()) return emptyList()
        val now = System.currentTimeMillis()
        val fresh = batch.filter { seen.putIfAbsent(it.id, now) == null }
        if (fresh.isEmpty()) return emptyList()

        _all.update { current ->
            (fresh + current)
                .distinctBy { it.id }
                .filter { it.despawnAt == null || it.despawnAt!! > now }
                .sortedByDescending { it.receivedAt }
                .take(1500)
        }
        withContext(Dispatchers.IO) { dao.insertAll(fresh.map { it.toEntity() }) }
        return fresh
    }

    private suspend fun prune() {
        val now = System.currentTimeMillis()
        _all.update { list -> list.filter { it.despawnAt == null || it.despawnAt!! > now } }
        dao.prune(now - 6 * 3600_000L)
    }

    suspend fun testFeed(url: String, auth: String = ""): Result<Int> = withContext(Dispatchers.IO) {
        runCatching { SpawnFeedParser.parse(fetch(url, auth), json).size }
    }

    fun loadDemoData() {
        val now = System.currentTimeMillis()
        val demo = listOf(
            ShinySpawn("d1", 147, "Dratini", 35.68950, 139.69170, 100, 512, 20, now + 600_000, "Japan", "Tokio"),
            ShinySpawn("d2", 374, "Beldum", 52.52000, 13.40500, 98, 640, 25, now + 420_000, "Deutschland", "Berlin"),
            ShinySpawn("d3", 133, "Eevee", 40.71280, -74.00600, 91, 380, 15, now + 900_000, "USA", "New York"),
            ShinySpawn("d4", 447, "Riolu", -33.86880, 151.20930, 100, 720, 30, now + 300_000, "Australien", "Sydney"),
            ShinySpawn("d5", 633, "Deino", 48.85660, 2.35220, 96, 455, 18, now + 780_000, "Frankreich", "Paris"),
        )
        _all.value = demo
        seen.clear()
        demo.forEach { seen[it.id] = now }
    }
}
EOF

# ---------- Kotlin: Standort ----------
write "$P/location/UserLocationProvider.kt" <<'EOF'
package com.venice.shinycoords.location

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import androidx.core.content.ContextCompat
import com.venice.shinycoords.domain.model.LatLng
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class UserLocationProvider(private val context: Context) {

    private val _location = MutableStateFlow<LatLng?>(null)
    val location: StateFlow<LatLng?> = _location.asStateFlow()

    private val listener = object : LocationListener {
        override fun onLocationChanged(loc: Location) {
            _location.value = LatLng(loc.latitude, loc.longitude)
        }
        override fun onProviderEnabled(provider: String) {}
        override fun onProviderDisabled(provider: String) {}
        @Deprecated("Deprecated in Java")
        override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
    }

    fun hasPermission(): Boolean =
        ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED ||
        ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED

    fun start() {
        if (!hasPermission()) return
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager ?: return
        runCatching {
            lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, 60_000L, 200f, listener)
            lm.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 60_000L, 200f, listener)
        }
        val last = runCatching {
            lm.getLastKnownLocation(LocationManager.GPS_PROVIDER)
                ?: lm.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
        }.getOrNull()
        last?.let { _location.value = LatLng(it.latitude, it.longitude) }
    }

    fun stop() {
        val lm = context.getSystemService(Context.LOCATION_SERVICE) as? LocationManager ?: return
        runCatching { lm.removeUpdates(listener) }
    }
}
EOF

# ---------- Kotlin: Service ----------
write "$P/service/SpawnTrackingService.kt" <<'EOF'
package com.venice.shinycoords.service

import android.app.*
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.venice.shinycoords.R
import com.venice.shinycoords.ShinyCoordsApp
import com.venice.shinycoords.domain.model.ShinySpawn
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.collectLatest

class SpawnTrackingService : Service() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createChannels()
        startForeground(ONGOING_ID, ongoingNotification("Starte Radar ..."))
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val container = ShinyCoordsApp.container(this)
        val repo = container.repository
        val settings = container.settings
        repo.start()

        scope.launch {
            repo.spawns.collectLatest { list ->
                notificationManager().notify(ONGOING_ID, ongoingNotification("${list.size} aktive Treffer"))
            }
        }

        scope.launch {
            var notify = true
            launch { settings.config.collect { notify = it.notify } }
            repo.events.collect { spawn -> if (notify) notifySpawn(spawn) }
        }
        return START_STICKY
    }

    private fun notifySpawn(spawn: ShinySpawn) {
        val copyIntent = Intent(this, NotificationActionReceiver::class.java).apply {
            action = NotificationActionReceiver.ACTION_COPY
            putExtra("coords", spawn.coords)
        }
        val mapIntent = Intent(Intent.ACTION_VIEW, Uri.parse(spawn.mapsUrl))

        val ivText = spawn.iv?.let { " - $it IV" } ?: ""
        val cpText = spawn.cp?.let { " - CP $it" } ?: ""
        val place = listOfNotNull(spawn.city, spawn.country).joinToString(", ")

        val n = NotificationCompat.Builder(this, CHANNEL_SPAWNS)
            .setSmallIcon(R.drawable.ic_shiny_star)
            .setContentTitle("Shiny-Check: ${spawn.name}$ivText$cpText")
            .setContentText(spawn.coords + if (place.isNotBlank()) " - $place" else "")
            .setStyle(NotificationCompat.BigTextStyle().bigText("${spawn.coords}\n$place"))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .addAction(0, "Koordinaten kopieren",
                PendingIntent.getBroadcast(this, spawn.id.hashCode(), copyIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
            .addAction(0, "Karte",
                PendingIntent.getActivity(this, spawn.id.hashCode() + 1, mapIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
            .build()

        notificationManager().notify(spawn.id.hashCode(), n)
    }

    private fun ongoingNotification(text: String): Notification =
        NotificationCompat.Builder(this, CHANNEL_ONGOING)
            .setSmallIcon(R.drawable.ic_shiny_star)
            .setContentTitle("Shiny Radar laeuft")
            .setContentText(text)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

    private fun createChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = notificationManager()
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_SPAWNS, "Neue Shiny-Spawns", NotificationManager.IMPORTANCE_HIGH)
        )
        nm.createNotificationChannel(
            NotificationChannel(CHANNEL_ONGOING, "Radar-Status", NotificationManager.IMPORTANCE_LOW)
        )
    }

    private fun notificationManager() =
        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    override fun onDestroy() { scope.cancel(); super.onDestroy() }

    companion object {
        const val CHANNEL_SPAWNS = "shiny_spawns"
        const val CHANNEL_ONGOING = "radar_status"
        const val ONGOING_ID = 1001

        fun start(ctx: Context) { ctx.startForegroundService(Intent(ctx, SpawnTrackingService::class.java)) }
        fun stop(ctx: Context) { ctx.stopService(Intent(ctx, SpawnTrackingService::class.java)) }
    }
}
EOF

write "$P/service/NotificationActionReceiver.kt" <<'EOF'
package com.venice.shinycoords.service

import android.content.BroadcastReceiver
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.widget.Toast

class NotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_COPY) return
        val coords = intent.getStringExtra("coords") ?: return
        val cm = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        cm.setPrimaryClip(ClipData.newPlainText("Pokemon GO Koordinaten", coords))
        Toast.makeText(context, "Kopiert: $coords", Toast.LENGTH_SHORT).show()
    }

    companion object { const val ACTION_COPY = "com.venice.shinycoords.COPY_COORDS" }
}
EOF

# ---------- Kotlin: App / Activity ----------
write "$P/ShinyCoordsApp.kt" <<'EOF'
package com.venice.shinycoords

import android.app.Application
import android.content.Context
import com.venice.shinycoords.data.SettingsStore
import com.venice.shinycoords.data.SpawnRepository
import com.venice.shinycoords.data.local.AppDatabase
import com.venice.shinycoords.data.remote.ShinyCatalog
import com.venice.shinycoords.location.UserLocationProvider
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import java.util.concurrent.TimeUnit

class AppContainer(context: Context) {
    val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
        coerceInputValues = true
    }

    val http: OkHttpClient = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(20, TimeUnit.SECONDS)
        .retryOnConnectionFailure(true)
        .build()

    val settings = SettingsStore(context)
    val location = UserLocationProvider(context)
    val catalog = ShinyCatalog(http, json)
    val db = AppDatabase.get(context)

    val repository = SpawnRepository(http, json, settings, db.spawnDao(), catalog, location)
}

class ShinyCoordsApp : Application() {
    override fun onCreate() { super.onCreate(); instance = this }

    companion object {
        private lateinit var instance: ShinyCoordsApp
        private lateinit var containerRef: AppContainer

        fun container(ctx: Context): AppContainer {
            if (!::containerRef.isInitialized) containerRef = AppContainer(ctx.applicationContext)
            return containerRef
        }
    }
}
EOF

write "$P/MainActivity.kt" <<'EOF'
package com.venice.shinycoords

import android.Manifest
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.lifecycle.viewmodel.compose.viewModel
import com.venice.shinycoords.service.SpawnTrackingService
import com.venice.shinycoords.ui.AppRoot
import com.venice.shinycoords.ui.FeedViewModel
import com.venice.shinycoords.ui.FeedViewModelFactory
import com.venice.shinycoords.ui.theme.ShinyRadarTheme

class MainActivity : ComponentActivity() {

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val container = ShinyCoordsApp.container(this)

        val wanted = buildList {
            add(Manifest.permission.ACCESS_FINE_LOCATION)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                add(Manifest.permission.POST_NOTIFICATIONS)
            }
        }
        permissionLauncher.launch(wanted.toTypedArray())

        container.location.start()
        SpawnTrackingService.start(this)

        setContent {
            ShinyRadarTheme {
                val vm: FeedViewModel = viewModel(factory = FeedViewModelFactory(container))
                AppRoot(vm)
            }
        }
    }
}
EOF

# ---------- Kotlin: UI ----------
write "$P/ui/theme/Theme.kt" <<'EOF'
package com.venice.shinycoords.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val Dark = darkColorScheme(
    primary = Color(0xFF4DD0C4),
    secondary = Color(0xFFFF7AB6),
    tertiary = Color(0xFFFFD54F),
    background = Color(0xFF0E1116),
    surface = Color(0xFF161B22),
    surfaceVariant = Color(0xFF1F2630),
    onSurface = Color(0xFFE6EDF3),
)

@Composable
fun ShinyRadarTheme(content: @Composable () -> Unit) {
    MaterialTheme(colorScheme = Dark, content = content)
}
EOF

write "$P/ui/FeedViewModel.kt" <<'EOF'
package com.venice.shinycoords.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.venice.shinycoords.AppContainer
import com.venice.shinycoords.domain.model.ShinySpawn
import com.venice.shinycoords.util.Geo
import com.venice.shinycoords.util.SpoofCooldown
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class FeedViewModel(private val c: AppContainer) : ViewModel() {

    val spawns: StateFlow<List<ShinySpawn>> = c.repository.spawns
    val status: StateFlow<String> = c.repository.status
    val userLocation = c.location.location
    val config = c.settings.config.stateIn(viewModelScope, SharingStarted.Eagerly, null)
    val filter = c.settings.filter.stateIn(viewModelScope, SharingStarted.Eagerly, null)

    private val ticker = flow {
        while (true) { emit(System.currentTimeMillis()); delay(1000) }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), System.currentTimeMillis())
    val now: StateFlow<Long> = ticker

    fun distanceText(spawn: ShinySpawn): String? {
        val u = userLocation.value ?: return null
        return Geo.format(Geo.distanceKm(u.lat, u.lng, spawn.lat, spawn.lng))
    }

    fun cooldownText(spawn: ShinySpawn): String? {
        val u = userLocation.value ?: return null
        val km = Geo.distanceKm(u.lat, u.lng, spawn.lat, spawn.lng)
        val secs = SpoofCooldown.requiredSeconds(km)
        return if (secs == 0L) "kein Cooldown" else "Cooldown ${SpoofCooldown.format(secs)}"
    }

    fun setFeedUrl(v: String) = viewModelScope.launch { c.settings.setFeedUrl(v) }
    fun setAuth(v: String) = viewModelScope.launch { c.settings.setAuthHeader(v) }
    fun setPoll(v: Int) = viewModelScope.launch { c.settings.setPollSeconds(v) }
    fun setNotify(v: Boolean) = viewModelScope.launch { c.settings.setNotify(v) }
    fun setMinIv(v: Int) = viewModelScope.launch { c.settings.setMinIv(v) }
    fun setMinCp(v: Int) = viewModelScope.launch { c.settings.setMinCp(v) }
    fun setMaxDistance(v: Int) = viewModelScope.launch { c.settings.setMaxDistance(v) }
    fun setShinyOnly(v: Boolean) = viewModelScope.launch { c.settings.setShinyOnly(v) }
    fun setRarityOnly(v: Boolean) = viewModelScope.launch { c.settings.setRarityOnly(v) }
    fun setFailover(v: Boolean) = viewModelScope.launch { c.settings.setFailover(v) }

    fun testFeed(url: String, auth: String, onResult: (String) -> Unit) = viewModelScope.launch {
        val r = c.repository.testFeed(url, auth)
        onResult(r.fold(
            onSuccess = { "OK - $it Eintraege geparst" },
            onFailure = { "Fehler: ${it.message}" },
        ))
    }

    fun loadDemo() = c.repository.loadDemoData()
    fun restartPolling() = c.repository.restart()
}

class FeedViewModelFactory(private val c: AppContainer) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T = FeedViewModel(c) as T
}
EOF

write "$P/ui/AppRoot.kt" <<'EOF'
package com.venice.shinycoords.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.venice.shinycoords.ui.feed.FeedScreen
import com.venice.shinycoords.ui.settings.SettingsScreen

@Composable
fun AppRoot(vm: FeedViewModel) {
    var tab by remember { mutableIntStateOf(0) }
    Scaffold(
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    selected = tab == 0, onClick = { tab = 0 },
                    icon = { Icon(Icons.Filled.Star, "Feed") }, label = { Text("Radar") },
                )
                NavigationBarItem(
                    selected = tab == 1, onClick = { tab = 1 },
                    icon = { Icon(Icons.Filled.Settings, "Einstellungen") }, label = { Text("Setup") },
                )
            }
        }
    ) { pad ->
        when (tab) {
            0 -> FeedScreen(vm, Modifier.padding(pad))
            else -> SettingsScreen(vm, Modifier.padding(pad))
        }
    }
}
EOF

write "$P/ui/feed/FeedScreen.kt" <<'EOF'
package com.venice.shinycoords.ui.feed

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.Toast
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.venice.shinycoords.domain.model.ShinySpawn
import com.venice.shinycoords.ui.FeedViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FeedScreen(vm: FeedViewModel, modifier: Modifier = Modifier) {
    val spawns by vm.spawns.collectAsStateWithLifecycle()
    val status by vm.status.collectAsStateWithLifecycle()
    val now by vm.now.collectAsStateWithLifecycle()
    val filter by vm.filter.collectAsStateWithLifecycle()

    Scaffold(
        modifier = modifier,
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Shiny Radar", fontWeight = FontWeight.Bold)
                        Text(status, style = MaterialTheme.typography.labelSmall)
                    }
                },
                actions = {
                    Text("${spawns.size}", style = MaterialTheme.typography.titleMedium,
                        modifier = Modifier.padding(end = 8.dp))
                }
            )
        }
    ) { pad ->
        Column(Modifier.padding(pad)) {
            FilterRow(filter, vm)

            if (spawns.isEmpty()) {
                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("Keine Treffer im Filter")
                        Spacer(Modifier.height(12.dp))
                        Button(onClick = { vm.loadDemo() }) { Text("Demo-Daten laden") }
                    }
                }
            } else {
                LazyColumn(
                    contentPadding = PaddingValues(12.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    items(spawns, key = { it.id }) { spawn -> SpawnCard(spawn, vm, now) }
                }
            }
        }
    }
}

@Composable
private fun FilterRow(filter: com.venice.shinycoords.domain.model.SpawnFilter?, vm: FeedViewModel) {
    val f = filter ?: return
    Row(
        Modifier.horizontalScroll(rememberScrollState()).padding(horizontal = 12.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        FilterChip(f.minIv >= 90, { vm.setMinIv(if (f.minIv >= 90) 0 else 90) }, { Text("IV 90+") })
        FilterChip(f.minCp > 0, { vm.setMinCp(if (f.minCp > 0) 0 else 1000) }, { Text("CP 1000+") })
        FilterChip(f.rarityOnly, { vm.setRarityOnly(!f.rarityOnly) }, { Text("Selten") })
        FilterChip(
            f.maxDistanceKm > 0,
            { vm.setMaxDistance(if (f.maxDistanceKm > 0) 0 else 200) },
            { Text(if (f.maxDistanceKm > 0) "bis ${f.maxDistanceKm} km" else "Distanz") },
        )
    }
}

@Composable
private fun SpawnCard(spawn: ShinySpawn, vm: FeedViewModel, now: Long) {
    val ctx = LocalContext.current
    val left = spawn.secondsUntilDespawn(now)

    Card(Modifier.fillMaxWidth()) {
        Column(Modifier.padding(14.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(spawn.name, style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
                if (spawn.iv != null) {
                    val color = when {
                        spawn.iv >= 100 -> MaterialTheme.colorScheme.tertiary
                        spawn.iv >= 90 -> MaterialTheme.colorScheme.primary
                        else -> MaterialTheme.colorScheme.surfaceVariant
                    }
                    Surface(color = color, shape = MaterialTheme.shapes.small) {
                        Text("${spawn.iv} IV", Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
                            style = MaterialTheme.typography.labelMedium)
                    }
                }
            }

            Spacer(Modifier.height(6.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                spawn.cp?.let { Text("CP $it", style = MaterialTheme.typography.bodySmall) }
                spawn.level?.let { Text("Lv $it", style = MaterialTheme.typography.bodySmall) }
                left?.let {
                    Text("noch ${it / 60}:%02d".format(it % 60),
                        style = MaterialTheme.typography.bodySmall,
                        color = if (it < 120) MaterialTheme.colorScheme.secondary
                                else MaterialTheme.colorScheme.onSurface)
                }
            }

            Spacer(Modifier.height(4.dp))

            listOfNotNull(spawn.city, spawn.country).takeIf { it.isNotEmpty() }?.let {
                Text(it.joinToString(", "), style = MaterialTheme.typography.bodySmall)
            }

            Text(spawn.coords, fontFamily = FontFamily.Monospace,
                style = MaterialTheme.typography.bodyMedium)

            vm.distanceText(spawn)?.let {
                Text("$it entfernt - ${vm.cooldownText(spawn)}", style = MaterialTheme.typography.labelSmall)
            }

            Spacer(Modifier.height(10.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(onClick = { copy(ctx, spawn.coords) }) { Text("Kopieren") }
                OutlinedButton(onClick = { openMap(ctx, spawn.mapsUrl) }) { Text("Karte") }
                OutlinedButton(onClick = { copy(ctx, spawn.mapsUrl) }) { Text("Maps-Link") }
            }
        }
    }
}

private fun copy(ctx: Context, text: String) {
    val cm = ctx.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
    cm.setPrimaryClip(ClipData.newPlainText("Pokemon GO Koordinaten", text))
    Toast.makeText(ctx, text, Toast.LENGTH_SHORT).show()
}

private fun openMap(ctx: Context, url: String) {
    runCatching { ctx.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url))) }
}
EOF

write "$P/ui/settings/SettingsScreen.kt" <<'EOF'
package com.venice.shinycoords.ui.settings

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.venice.shinycoords.data.SettingsStore
import com.venice.shinycoords.ui.FeedViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(vm: FeedViewModel, modifier: Modifier = Modifier) {
    val cfg by vm.config.collectAsStateWithLifecycle()
    val filter by vm.filter.collectAsStateWithLifecycle()

    var url by remember(cfg?.feedUrl) { mutableStateOf(cfg?.feedUrl.orEmpty()) }
    var auth by remember(cfg?.authHeader) { mutableStateOf(cfg?.authHeader.orEmpty()) }
    var testResult by remember { mutableStateOf("") }

    Scaffold(modifier = modifier, topBar = { TopAppBar(title = { Text("Setup") }) }) { pad ->
        Column(
            Modifier.padding(pad).verticalScroll(rememberScrollState()).padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            Text("Datenquelle", style = MaterialTheme.typography.titleMedium)

            OutlinedTextField(
                value = url, onValueChange = { url = it },
                label = { Text("Feed-URL (JSON)") },
                modifier = Modifier.fillMaxWidth(),
                textStyle = LocalTextStyle.current.copy(fontFamily = FontFamily.Monospace),
            )

            Text("Kandidaten (antippen zum Uebernehmen):",
                style = MaterialTheme.typography.labelMedium)
            SettingsStore.CANDIDATE_FEEDS.forEach { candidate ->
                TextButton(onClick = { url = candidate }) {
                    Text(candidate, style = MaterialTheme.typography.labelSmall)
                }
            }

            OutlinedTextField(
                value = auth, onValueChange = { auth = it },
                label = { Text("Auth-Header (optional, z. B. Discord Bot-Token)") },
                modifier = Modifier.fillMaxWidth(),
                textStyle = LocalTextStyle.current.copy(fontFamily = FontFamily.Monospace),
            )

            Row(verticalAlignment = Alignment.CenterVertically) {
                Switch(checked = cfg?.failover == true, onCheckedChange = { vm.setFailover(it) })
                Spacer(Modifier.width(12.dp))
                Text("Automatischer Failover auf Kandidaten")
            }

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Button(onClick = { vm.setFeedUrl(url); vm.setAuth(auth); vm.restartPolling() }) {
                    Text("Speichern")
                }
                OutlinedButton(onClick = { vm.testFeed(url, auth) { testResult = it } }) {
                    Text("Feed testen")
                }
            }
            if (testResult.isNotBlank()) {
                Text(testResult, style = MaterialTheme.typography.labelMedium)
            }

            Text(
                "Der Parser versteht Poracle-/PokeAlarm-Webhooks, GeoJSON-Features, flache JSON-Arrays " +
                "und Discord-Nachrichten (Koordinaten im Text). Felder: lat/latitude, lng/longitude, " +
                "pokemon_id/name, iv, cp, level, despawn_time.",
                style = MaterialTheme.typography.bodySmall,
            )

            HorizontalDivider()

            Text("Polling", style = MaterialTheme.typography.titleMedium)
            Text("Intervall: ${cfg?.pollSeconds ?: 15} s", style = MaterialTheme.typography.bodyMedium)
            Slider(
                value = (cfg?.pollSeconds ?: 15).toFloat(),
                onValueChange = { vm.setPoll(it.toInt()) },
                valueRange = 5f..120f,
            )

            HorizontalDivider()

            Text("Benachrichtigungen", style = MaterialTheme.typography.titleMedium)
            Row(verticalAlignment = Alignment.CenterVertically) {
                Switch(checked = cfg?.notify == true, onCheckedChange = { vm.setNotify(it) })
                Spacer(Modifier.width(12.dp))
                Text("Bei neuem Spawn benachrichtigen")
            }

            HorizontalDivider()

            Text("Filter", style = MaterialTheme.typography.titleMedium)
            Text("Min. IV: ${filter?.minIv ?: 0}")
            Slider(
                value = (filter?.minIv ?: 0).toFloat(),
                onValueChange = { vm.setMinIv(it.toInt()) },
                valueRange = 0f..100f,
            )
            Row(verticalAlignment = Alignment.CenterVertically) {
                Switch(checked = filter?.rarityOnly == true, onCheckedChange = { vm.setRarityOnly(it) })
                Spacer(Modifier.width(12.dp))
                Text("Nur seltene Arten")
            }

            HorizontalDivider()

            Button(onClick = { vm.loadDemo() }) { Text("Demo-Daten in die Liste laden") }

            Spacer(Modifier.height(24.dp))
        }
    }
}
EOF

echo
echo "Fertig. Dateien:"
find . -type f | sort
echo
echo "Naechste Schritte:"
echo "  1) Repo anlegen, Ordner per Drag-and-Drop hochladen"
echo "  2) Settings > Actions > General > Workflow permissions = Read and write"
echo "  3) Actions > 'Build ShinyRadar APK' > Run workflow"
echo "  4) Link: https://github.com/USER/REPO/releases/latest/download/ShinyRadar-debug.apk"
SCRIPT
bash generate.sh
