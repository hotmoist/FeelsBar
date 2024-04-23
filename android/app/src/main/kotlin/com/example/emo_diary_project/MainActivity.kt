package com.example.emo_diary_project

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel


import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.lang.Exception
import java.time.Duration
import java.time.Instant
import java.time.ZoneId
import java.util.Calendar


import org.jsoup.Jsoup
import org.jsoup.nodes.Document

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.example.emo_diary_project/data"
//    private lateinit var myFlutterEngine: DFlutterEngine


    val requestPermissionActivityContract = PermissionController.createRequestPermissionResultContract()
    val requestPermissions = registerForActivityResult(requestPermissionActivityContract) {granted ->
        if (granted.containsAll(PERMISSIONS)) {
            // permission granted
        } else {
            // lack of permission
        }
    }
    val PERMISSIONS =
        setOf(
            HealthPermission.getReadPermission(androidx.health.connect.client.records.StepsRecord::class),
            HealthPermission.getWritePermission(androidx.health.connect.client.records.StepsRecord::class),
            HealthPermission.getReadPermission(androidx.health.connect.client.records.SleepSessionRecord::class),
        )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
//        myFlutterEngine = DFlutterEngine(this, flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermission" -> {
                    requestUsageStatePermission(this)
                    checkPermissions()
                }
                "getSleepData" -> {
                    fetchSleepData(result)
                }
                "getStepData" -> {
                    fetchStepData(result)
                }
                "getUsageData" -> {
                    requestUsageStatePermission(this)
                    fetchAppUsageStats(this, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkPermissions(){
        val healthConnectClient = HealthConnectClient.getOrCreate(applicationContext)

        CoroutineScope(Dispatchers.IO).launch {
            val granted = healthConnectClient.permissionController.getGrantedPermissions()

            if(!granted.containsAll(PERMISSIONS)){
                requestPermissions.launch(PERMISSIONS)
            }
        }
    }


    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun fetchAppUsageStats(context: Context, result: MethodChannel.Result){
        CoroutineScope(Dispatchers.IO).launch {
            try {
                var fetchData = ""
                val usageStatsManager =
                    context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

                val calendar = Calendar.getInstance()
                val endTime = calendar.timeInMillis
                calendar.set(Calendar.HOUR_OF_DAY, 0)
                calendar.set(Calendar.MINUTE, 0)
                calendar.set(Calendar.SECOND, 0)
                val startTime = calendar.timeInMillis

                val queryUsageStats = usageStatsManager.queryUsageStats(
                    UsageStatsManager.INTERVAL_DAILY, startTime, endTime
                )

                for (us in queryUsageStats) {
                    if (us.totalTimeInForeground > 0) {
                        val category = getCategory(us.packageName, context)
                        fetchData += getAppNameJsoup(
                            us.packageName,
                            context
                        ) + "|" + category + "|" + ((us.totalTimeInForeground / 1000).toInt()) + "\n"
                    }
                }

                withContext(Dispatchers.Main) {
                    result.success(
                        fetchData
                    )
                }
            } catch (e: Exception){
                withContext(Dispatchers.Main){
                    result.error("ERROR_FETCHING_DATA", e.message, null)
                }
            }
        }
    }

    private fun isAccessGranted(context: Context): Boolean{
        val appOpManager = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOpManager.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(), context.packageName)
        } else {
            appOpManager.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, android.os.Process.myUid(), context.packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatePermission(context: Context){
        CoroutineScope(Dispatchers.IO).launch {
            async{
                if(!isAccessGranted(context)){
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                    ContextCompat.startActivity(context, intent, null)
                }
            }.await()
        }
    }

    private fun getCategory(packageName: String, context: Context):String {
        val prefs: SharedPreferences = context.getSharedPreferences("diary", Context.MODE_PRIVATE)
        var category: String = prefs.getString("$packageName.category", "NONE").toString()
        if(category == "NONE"){
            val url = "https://play.google.com/store/apps/details?id=$packageName"
            try {
                val doc: Document = Jsoup.connect(url).get()
                val index = doc.body().data().indexOf("applicationCategory")
                val simpleString = doc.body().data().subSequence(index, index + 100)
                category = simpleString.split(":")[1].split(":")[0].split(",")[0]
            } catch (e: Exception){
                category = "\"UNKNOWN\""
            }
            prefs.edit().putString("$packageName.category", category)
        }
            return category
    }


    private fun getAppNameJsoup(packageName: String, context: Context): String {
        val prefs:SharedPreferences = context.getSharedPreferences("diary", Context.MODE_PRIVATE)
        var name: String = prefs.getString("$packageName.name", "NONE").toString()
        if(name == "NONE"){
            val url = "https://play.google.com/store/apps/details?id=$packageName"
            try {
                val doc: Document = Jsoup.connect(url).get()
                name = doc.select("h1").first()?.text().toString()
            } catch (e: Exception){
                name =  getAppNameFromPackageName(packageName, context)
            }
            prefs.edit().putString("$packageName.name", name)
        }

        return name
    }

    private fun getAppNameFromPackageName(packageName: String, context: Context): String {
        val packageManager = context.packageManager
        val appInfo: ApplicationInfo
        try {
            appInfo = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
        } catch (e: PackageManager.NameNotFoundException) {
            // Handle the exception if the package name is not found
            return getAppNameFromPackage(packageName, context)
        }
        return packageManager.getApplicationLabel(appInfo).toString()
    }

    private fun getAppNameFromPackage(packageName: String, context: Context): String{
        val mainIntent = Intent(Intent.ACTION_MAIN, null)
        mainIntent.addCategory(Intent.CATEGORY_LAUNCHER)

        val pkgAppsList = context.packageManager.queryIntentActivities(mainIntent, 0)

        for (app in pkgAppsList) {
            if (app.activityInfo.packageName.equals(packageName)){
                return app.activityInfo.loadLabel(context.packageManager).toString()
            }
        }
        return packageName
    }

    private fun fetchSleepData(result: MethodChannel.Result){
        val healthConnectClient = HealthConnectClient.getOrCreate(applicationContext)

        CoroutineScope(Dispatchers.IO).launch {
            try{
                val granted = healthConnectClient.permissionController.getGrantedPermissions()

                if(!granted.containsAll(PERMISSIONS)){
                    async { requestPermissions.launch(PERMISSIONS)}.await()
                }

                    val endTime = Instant.now()
                    val timeZone = ZoneId.of("Asia/Seoul")
                    // 현재 로컬 날짜 및 시간으로 변환 (예 시스템 기본 시간대를 사용)
                    val currentLocalDateTime = endTime.atZone(ZoneId.systemDefault())
                    // 오늘 자정의 로컬 날짜 및 시간
                    val startOfTodayLocalDateTime = currentLocalDateTime.toLocalDate().atStartOfDay(ZoneId.systemDefault())
                    // 오늘 자정의 로컬 날자 및 시간 다시 Instant로 변환
                    val startTime = startOfTodayLocalDateTime.toInstant()

                    val sleepData = healthConnectClient.readRecords(
                        ReadRecordsRequest(
                            recordType = androidx.health.connect.client.records.SleepSessionRecord::class,
                            timeRangeFilter = TimeRangeFilter.Companion.between(Instant.now().minus(Duration.ofDays(1)), Instant.now())
                        )
                    )
//                    val sleepStages = sleepData.records.filterIsInstance<androidx.health.connect.client.records.SleepSessionRecord>()
//                    val sleepStageStrings = sleepStages.map { "${it.startTime} to ${it.endTime}" }
                    val sleepStages = sleepData.records.filterIsInstance<androidx.health.connect.client.records.SleepSessionRecord>()
                    val sleepStageStrings = sleepStages.map {
                        val localStart = it.startTime.atZone(timeZone).toString().substringBefore('+')
                        val localEnd = it.endTime.atZone(timeZone).toString().substringBefore("+")
                        "$localStart to $localEnd"
                    }.lastOrNull()

                    result.success(sleepStageStrings.toString())
            } catch (e :Exception){
                withContext(Dispatchers.Main){
                    result.error("ERROR_FETCHING_DATA", e.message, null)
                }
            }
        }
    }

    private fun fetchStepData(result: MethodChannel.Result) {
        val healthConnectClient = HealthConnectClient.getOrCreate(applicationContext)

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val granted = healthConnectClient.permissionController.getGrantedPermissions()

                if(!granted.containsAll(PERMISSIONS)){
                    async { requestPermissions.launch(PERMISSIONS)}.await()
                }

//                if(granted.containsAll(PERMISSIONS)){

                    val endTime = Instant.now()
                    // 현재 로컬 날짜 및 시간으로 변환 (예: 시스템 기본 시간대를 사용)
                    val currentLocalDateTime = endTime.atZone(ZoneId.systemDefault())

                    // 오늘 자정의 로컬 날짜 및 시간을 구합니다.
                    val startOfTodayLocalDateTime = currentLocalDateTime.toLocalDate().atStartOfDay(ZoneId.systemDefault())

                    // 오늘 자정의 로컬 날짜 및 시간을 다시 Instant로 변환합니다.
                    val startTime = startOfTodayLocalDateTime.toInstant()

                    val response = healthConnectClient.aggregate(
                        AggregateRequest(
                            metrics = setOf(androidx.health.connect.client.records.StepsRecord.COUNT_TOTAL),
                            timeRangeFilter = androidx.health.connect.client.time.TimeRangeFilter.Companion.between(
                                startTime, endTime)
                        )
                    )

                    val stepCount = response[androidx.health.connect.client.records.StepsRecord.COUNT_TOTAL]

                    withContext(Dispatchers.Main){
                        result.success(stepCount.toString()) // 데이터 전달에 대해 수정 필요
                    }
//                }else{
//                    requestPermissions.launch(PERMISSIONS)
//                }

            } catch (e: Exception) {
                withContext(Dispatchers.Main){
                    result.error("ERROR_FETCHING_DATA", e.message, null)
                }
            }
        }
    }

}
