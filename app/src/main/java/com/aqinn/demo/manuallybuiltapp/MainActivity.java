package com.aqinn.demo.manuallybuiltapp;

import android.app.Activity;
import android.os.Build;
import android.os.Bundle;
import android.widget.TextView;

/**
 * Created by AllanZhong on 2023/5/17.
 */
public class MainActivity extends Activity {

    private TextView tv1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        tv1 = (TextView) findViewById(R.id.tv1);

        tv1.setText(getString(R.string.app_name));
//        int minSdkVersion = getApplicationContext().getApplicationInfo().minSdkVersion;
//        int targetSdkVersion = getApplicationContext().getApplicationInfo().targetSdkVersion;
//        tv1.setText("minSdkVersion: " + minSdkVersion + ", targetSdkVersion: " + targetSdkVersion);
    }

}
