package com.example.shooter

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.abs
import kotlin.math.log10
import kotlinx.coroutines.*
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity: FlutterActivity() {
    private val CHANNEL = "shooter.mic_service"
    private var audioRecord: AudioRecord? = null
    private var isRecording = AtomicBoolean(false)
    private var recordingJob: Job? = null
    private var lastLevel = 0.0
    
    // Noise floor tracking for better sensitivity
    private val recentLevels = ArrayList<Double>()
    private val maxRecentLevels = 20 // Keep track of recent background noise levels
    
    companion object {
        private const val SAMPLE_RATE = 44100
        private const val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO
        private const val AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT
        private const val BUFFER_SIZE_FACTOR = 2
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startAudioMonitoring" -> {
                    startAudioMonitoring(result)
                }
                "stopAudioMonitoring" -> {
                    stopAudioMonitoring(result)
                }
                "getAudioLevel" -> {
                    result.success(lastLevel)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun startAudioMonitoring(result: MethodChannel.Result) {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "Microphone permission is required", null)
            return
        }
        
        if (isRecording.get()) {
            result.success(true)
            return
        }
        
        try {
            val minBufferSize = AudioRecord.getMinBufferSize(SAMPLE_RATE, CHANNEL_CONFIG, AUDIO_FORMAT)
            val bufferSize = minBufferSize * BUFFER_SIZE_FACTOR
            
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                SAMPLE_RATE,
                CHANNEL_CONFIG,
                AUDIO_FORMAT,
                bufferSize
            )
            
            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                result.error("INIT_FAILED", "Could not initialize AudioRecord", null)
                audioRecord?.release()
                audioRecord = null
                return
            }
            
            // Reset noise tracking
            recentLevels.clear()
            
            isRecording.set(true)
            audioRecord?.startRecording()
            
            // Use coroutines for audio processing to be more efficient
            recordingJob = CoroutineScope(Dispatchers.IO).launch {
                val audioBuffer = ShortArray(bufferSize / 2)
                
                while (isRecording.get()) {
                    val readSize = audioRecord?.read(audioBuffer, 0, audioBuffer.size) ?: 0
                    if (readSize > 0) {
                        calculateLevel(audioBuffer, readSize)
                    }
                    delay(20) // Small pause between reads
                }
            }
            
            result.success(true)
        } catch (e: Exception) {
            result.error("RECORD_FAILED", e.message, e.stackTraceToString())
        }
    }
    
    private fun stopAudioMonitoring(result: MethodChannel.Result) {
        if (isRecording.get()) {
            isRecording.set(false)
            recordingJob?.cancel()
            recordingJob = null
            
            try {
                audioRecord?.stop()
                audioRecord?.release()
                audioRecord = null
            } catch (e: Exception) {
                result.error("STOP_FAILED", e.message, e.stackTraceToString())
                return
            }
        }
        
        result.success(true)
    }
    
    private fun calculateLevel(buffer: ShortArray, readSize: Int) {
        var sum = 0.0
        
        // Calculate RMS (root mean square) of the buffer
        for (i in 0 until readSize) {
            sum += buffer[i] * buffer[i]
        }
        
        // Safety check to avoid division by zero or negative values
        if (sum <= 0.0 || readSize <= 0) {
            return
        }
        
        val rms = Math.sqrt(sum / readSize)
        
        // Convert to decibels
        // Adding small value to avoid log(0)
        val db = 20 * log10(rms + 1)
        
        // Track the background noise levels to improve shot detection
        updateBackgroundNoiseLevels(db)
        
        // Calculate the noise floor (average background noise)
        val noiseFloor = if (recentLevels.size > 0) {
            recentLevels.average()
        } else {
            0.0
        }
        
        // Normalize to 0-100 range for Flutter side, but account for noise floor
        // A shot should be well above the noise floor
        val normalizedLevel = if (db > noiseFloor + 10) {
            // Scale from noise floor to max range (0-100)
            val scaledValue = ((db - noiseFloor) / 60.0) * 100.0
            scaledValue.coerceIn(0.0, 100.0)
        } else {
            0.0 // Below threshold, not significant
        }
        
        lastLevel = normalizedLevel
    }
    
    private fun updateBackgroundNoiseLevels(currentDb: Double) {
        // Only add low-level sounds to our background noise calculation
        // This helps establish a baseline for normal environmental noise
        if (currentDb < 70.0) { // Arbitrary threshold for "quiet" sounds
            recentLevels.add(currentDb)
            
            // Keep the list size limited
            if (recentLevels.size > maxRecentLevels) {
                recentLevels.removeAt(0)
            }
        }
    }
    
    override fun onDestroy() {
        stopAudioMonitoring(object : MethodChannel.Result {
            override fun success(result: Any?) {}
            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
            override fun notImplemented() {}
        })
        super.onDestroy()
    }
}
