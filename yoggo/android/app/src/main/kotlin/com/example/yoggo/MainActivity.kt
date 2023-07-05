package com.sayit.yoggo


import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.MediaRecorder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch




class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.sayit.yoggo/channel"
    private var path: String? = null
    private var recorder:MediaRecorder? =null
    private var isRecording = false
    private var job: Job? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setPath") {
                val path = call.argument<String>("path")
                if (path != null) {
                    this.path = path
                    handleReceivedPath(path)
                    println("startRecording() 호출")
                    startRecording()
                    result.success("Path received by Kotlin")
                } else {
                    result.error("INVALID_ARGUMENT", "Invalid argument", null)
                }
            } else if (call.method == "stopRecording") {
                stopRecording() // Kotlin 함수를 호출합니다.
                result.success(null) // 성공 결과를 반환합니다.
            } else {
                result.notImplemented()
            }
        }  
    }


    private fun handleReceivedPath(path: String) {
        // Kotlin에서 받은 path 값 처리하는 로직을 여기에 작성합니다.
        println("Received path from Flutter: $path")
    }


       private fun startRecording(){
        println("startRecording 시작, 시작path: $path")
        recorder = MediaRecorder().apply {
            setAudioSource(MediaRecorder.AudioSource.DEFAULT)
            setOutputFormat(MediaRecorder.OutputFormat.DEFAULT)
            setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            setOutputFile(path)
            prepare()
        }
        recorder?.start()
       // getDb()
        println("record시작 path: $path")
    } 

        private fun stopRecording(){
        println("코틀린: stopRecording 호출")
        recorder?.run{
            stop()
            release()
        recorder =null
    }
}

  private fun getDb() {
        recorder?.let {
            isRecording = true
            job = CoroutineScope(Dispatchers.Default).launch {
                while (isRecording) {
                    delay(3000L) //3초에 한번씩 데시벨을 측정
                    val amplitude = it.maxAmplitude
                    val db = 20 * kotlin.math.log10(amplitude.toDouble()) //진폭 to 데시벨
                    if (amplitude > 0) {
                        //진폭이 0 보다 크면 .. toDoSomething
                        //진폭이 0이하이면 데시벨이 -무한대로 나옵니다.
                    }
                }
            }
        }
    }
}