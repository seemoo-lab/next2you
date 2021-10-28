package com.seemoo.mstiegler.csidatacollector;

import android.content.Intent;
import android.os.Handler;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.seemoo.mstiegler.csidatacollector.util.DataHolder;
import com.seemoo.mstiegler.csidatacollector.util.Nexutil;

import java.util.Calendar;

public class SenderActivity extends AppCompatActivity {

    Thread senderThread;
    TextView applicationLog;
    Button startSendingButton;
    Button changeModeButton;
    EditText chanspecInput;
    EditText periodInput;
    Handler handler;
    long period;
    int messageCounter;
    String bw;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sender);
        applicationLog = findViewById(R.id.senderLog);
        applicationLog.setMovementMethod(new ScrollingMovementMethod());
        startSendingButton = findViewById(R.id.senderButton);
        changeModeButton = findViewById(R.id.collectionButton);
        chanspecInput = findViewById(R.id.sender_chanspec);
        periodInput = findViewById(R.id.editPeriod);
        DataHolder.setSendingStatus(false);
        handler = new Handler();
        Nexutil.getInstance(getApplicationContext());
        messageCounter = 0;
    }

    public void changeModeOnClick(View view){
        startActivity(new Intent(this, MainActivity.class));
    }

    public void startSendingOnClick(View view){
        if(startSendingButton.getText().equals("Start Sending")){
            DataHolder.setSendingStatus(true);
            chanspecInput.setEnabled(false);
            periodInput.setEnabled(false);
            changeModeButton.setEnabled(false);
            startSendingButton.setText("Stop Sending");
            if(chanspecInput.getText().toString().equals("")) {
                bw = DataHolder.defaultBandwidth;
                Nexutil.getInstance().setChanspec(DataHolder.defaultChannel, bw);
                newLineToLog("Channel specs set to default values " + DataHolder.defaultChannel + "/" + bw);
            }
            else{
                String[] params = chanspecInput.getText().toString().split("/");
                if(params.length!=2){
                    bw = DataHolder.defaultBandwidth;
                    Nexutil.getInstance().setChanspec(DataHolder.defaultChannel, bw);
                    newLineToLog("Channel specs invalid; proceed with default values " + DataHolder.defaultChannel + "/" + bw);
                }
                else{
                    // TODO: further check if chanspec is valid
                    bw = params[1];
                    Nexutil.getInstance().setChanspec(params[0], params[1]);
                    newLineToLog("Channel specs set to " + chanspecInput.getText().toString());
                }
            }
            if(periodInput.getText().toString().equals("")){
                period = 100;
                newLineToLog("No period defined. Shortest period (100 ms) will be used");
            }
            else
                period = Long.parseLong(periodInput.getText().toString());
            senderThread = new Thread() {
                @Override
                public void run() {
                    sendPeriodically();
                }
            };
            newLineToLog("Periodical broadcast initiated with " + bw + " MHz bandwidth and a period of " + period + " ms");
            senderThread.start();
        }
        else{
            DataHolder.setSendingStatus(false);
            chanspecInput.setEnabled(true);
            periodInput.setEnabled(true);
            changeModeButton.setEnabled(true);
            newLineToLog("Periodical broadcast stopped");
            startSendingButton.setText("Start Sending");
        }
    }

    private void newLineToLog(final String log){
        applicationLog.setText(applicationLog.getText() + "\n" + Calendar.getInstance().get(Calendar.HOUR_OF_DAY) + "-" + Calendar.getInstance().get(Calendar.MINUTE) + ": " + log);
    }

    public void sendPeriodically(){
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if(DataHolder.isSending()) {
                    runOnUiThread(new Runnable() {
                        public void run() {
                            if(bw.equals("20"))
                                Nexutil.getInstance().setIoctl(505);
                            else
                                Nexutil.getInstance().setIoctl(504);
                            messageCounter++;
                            if(messageCounter<=50 || messageCounter%500==0)
                                newLineToLog(messageCounter + ". message was sent.");
                        }
                    });
                    sendPeriodically();
                }
            }
        }, period);
    }

    public boolean handleMessage(Message msg){
        if(DataHolder.isSending()){
            Nexutil.getInstance().setIoctl(505);
            messageCounter++;
            newLineToLog(messageCounter + ". message was sent.");
            // long delay = (long) (period*(0.9+Math.random()*0.2));
            // use of line above decreases maximum packet rate
            handler.sendMessageDelayed(new Message(), period);
        }

        return true;
    }
}
