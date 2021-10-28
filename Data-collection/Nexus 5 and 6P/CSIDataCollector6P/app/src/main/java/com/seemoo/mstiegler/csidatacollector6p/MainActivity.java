package com.seemoo.mstiegler.csidatacollector6p;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.media.MediaScannerConnection;
import android.os.Environment;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.util.ArrayMap;
import android.util.ArraySet;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;

import com.seemoo.mstiegler.csidatacollector6p.util.DataHolder;
import com.seemoo.mstiegler.csidatacollector6p.util.Nexutil;

import java.io.File;
import java.io.FileWriter;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.SocketTimeoutException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Calendar;
import java.util.Locale;

public class MainActivity extends AppCompatActivity implements AdapterView.OnItemSelectedListener {

    Thread networkThread;
    DatagramSocket socket;
    byte[] message;

    TextView applicationLog;
    TextView devicesInRange;
    Button collectionButton;
    Button changeModeButton;
    Spinner spinner;
    ArrayAdapter<CharSequence> adapter;
    EditText chanspecInput;
    EditText labelInput;
    EditText nameInput;

    File folder;
    File outputFile;
    File labelFile;
    ArrayMap<String,File> outputMap;
    ArrayMap<String,File> labelMap;
    ArraySet<Integer> collocatedDevices;
    int sampleCounter;
    String label;
    String[] chanspec;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        checkAndRequestPermissions(this);
        applicationLog = findViewById(R.id.applicationLog);
        applicationLog.setMovementMethod(new ScrollingMovementMethod());
        devicesInRange = findViewById(R.id.devicesInRange);
        devicesInRange.setText("");
        collectionButton = findViewById(R.id.startCsiButton);
        changeModeButton = findViewById(R.id.senderButton);
        spinner = findViewById(R.id.spinner);
        adapter = ArrayAdapter.createFromResource(this,R.array.spinner_list, android.R.layout.simple_spinner_item);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);
        spinner.setOnItemSelectedListener(this);
        chanspecInput = findViewById(R.id.chanspec);
        labelInput = findViewById(R.id.editLabel);
        nameInput = findViewById(R.id.experimentName);
        sampleCounter = 0;
        DataHolder.setCollectionStatus(false);
        outputMap = new ArrayMap<>();
        labelMap = new ArrayMap<>();
        collocatedDevices = new ArraySet<>();

        folder = new File(Environment.getExternalStorageDirectory(),"CSI");
        if(!folder.exists())
            folder.mkdirs();
        outputFile = null;
        labelFile = null;

        // csi collection only available as soon as one of spinner's options has been chosen:
        collectionButton.setEnabled(false);

        Nexutil.getInstance(getApplicationContext());
        Nexutil.getInstance().restartInterface();
    }

    private final String[] PERMISSIONS = {
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    };

    //TODO: Handle situation when permissions not granted
    private void checkAndRequestPermissions(Activity activity) {
        int permissionWrite = ActivityCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        int permissionRead = ActivityCompat.checkSelfPermission(activity, Manifest.permission.READ_EXTERNAL_STORAGE);
        if (permissionWrite != PackageManager.PERMISSION_GRANTED || permissionRead != PackageManager.PERMISSION_GRANTED  ) {
            ActivityCompat.requestPermissions(
                    activity,
                    PERMISSIONS,
                    1
            );
        }
    }

    private int[] unpackFloats(long[] H, int nfft){
        int e_p, maxbit, e, i, pwr_shft = 0, e_zero, sgn;
        int n_out, e_shift;
        int[] He = new int[256];
        int[] Hout = new int[2*nfft];
        int vi, vq;
        int pOut = 0;
        long x, iq_mask, e_mask, sgnr_mask, sgni_mask;
        int nbits = 10;
        int shft = 0;
        int fmt = 1;
        int nman = 9;
        int nexp = 5;
        long k_tof_unpack_sgn_mask = (1L)<<31;
        iq_mask = (1<<(nman-1))- 1;
        e_mask = (1<<nexp)-1;
        e_p = (1<<(nexp-1));
        sgnr_mask = (1 << (nexp + 2*nman - 1));
        sgni_mask = (sgnr_mask >> nman);
        e_zero = -nman;
        n_out = (nfft << 1);
        e_shift = 1;
        maxbit = -e_p;
        for (i = 0; i < nfft; i++) {
            vi = (int)((H[i] >> (nexp + nman)) & iq_mask);
            vq = (int)((H[i] >> nexp) & iq_mask);
            e =   (int)(H[i] & e_mask);
            if (e >= e_p)
                e -= (e_p << 1);
            He[i] = e;
            x = vi | vq;
            if (x != 0) {
                long m = 0xffff0000L, b = 0xffffL;
                int s = 16;
                while (s > 0) {
                    if ((x & m)!=0) {
                        e += s;
                        x >>= s;
                    }
                    s >>= 1;
                    m = (m >> s) & b;
                    b >>= s;
                }
                if (e > maxbit)
                    maxbit = e;
            }
            if ((H[i] & sgnr_mask) != 0)
                vi |= k_tof_unpack_sgn_mask;
            if ((H[i] & sgni_mask) != 0)
                vq |= k_tof_unpack_sgn_mask;
            Hout[i<<1] = vi;
            Hout[(i<<1)+1] = vq;
        }
        shft = nbits - maxbit;
        for (i = 0; i < n_out; i++) {
            e = He[(i >> e_shift)] + shft;
            vi = Hout[pOut];
            sgn = 1;
            if ((vi & k_tof_unpack_sgn_mask) != 0) {
                sgn = -1;
                vi &= ~k_tof_unpack_sgn_mask;
            }
            if (e < e_zero) {
                vi = 0;
            } else if (e < 0) {
                e = -e;
                vi = (vi >> e);
            } else {
                vi = (vi << e);
            }
		    Hout[pOut] = (int)sgn*vi;
            pOut++;
        }
        return Hout;
    }

    private String csiDataToSample(byte[] data){
        double[] magnitudes = new double[256];
        double[] phases = new double[256];
        StringBuilder sample = new StringBuilder();
        int subcarriers;
        ByteBuffer buf = ByteBuffer.wrap(data);
        buf.order(ByteOrder.LITTLE_ENDIAN);
        byte[] unused = new byte[14];
        buf.get(unused,0,14);
        switch(chanspec[1]){
            case "20":
                subcarriers = 64;
                break;

            case "40":
                subcarriers = 128;
                break;

            default:
                subcarriers = 256;
                break;
        }

        int tmp;
        long[] packedfloats = new long[subcarriers];
        packedfloats[0] = 0;
        int i = 1;
        while (i < subcarriers) {
            tmp = buf.getInt();
            packedfloats[i] = tmp&0xffffffffL;
            i++;
        }
        int [] unpackedfloats = unpackFloats(packedfloats, subcarriers);
        for (i = 0; i < subcarriers; i++) {
            int real = unpackedfloats[2*i];
            int imag = unpackedfloats[2*i+1];
            magnitudes[i] = Math.sqrt(real*real+imag*imag);
            sample.append(String.format(Locale.US, "%.2f", magnitudes[i]));
            sample.append(" ");
            phases[i] = Math.atan2(imag,real);
        }
        for(i=0; i<subcarriers; i++){
            sample.append(String.format(Locale.US, "%.2f", phases[i]));
            sample.append(" ");
        }
        return sample.toString();
    }

    private void startCsiCollection(){
        DataHolder.setCollectionStatus(true);
        chanspecInput.setEnabled(false);
        labelInput.setEnabled(false);
        nameInput.setEnabled(false);
        changeModeButton.setEnabled(false);
        spinner.setEnabled(false);
        collectionButton.setText("Stop CSI Collection");
        if(chanspecInput.getText().toString().equals("")) {
            chanspec = new String[2];
            chanspec[0] = DataHolder.defaultChannel;
            chanspec[1] = DataHolder.defaultBandwidth;
            Nexutil.getInstance().setChanspec(DataHolder.defaultChannel, DataHolder.defaultBandwidth);
            newLineToLog("Channel specs set to default values " + DataHolder.defaultChannel + "/" + DataHolder.defaultBandwidth);
        }
        else{
            chanspec = chanspecInput.getText().toString().split("/");
            if(chanspec.length!=2){
                chanspec = new String[2];
                chanspec[0] = DataHolder.defaultChannel;
                chanspec[1] = DataHolder.defaultBandwidth;
                Nexutil.getInstance().setChanspec(DataHolder.defaultChannel, DataHolder.defaultBandwidth);
                newLineToLog("Channel specs invalid; proceed with default values " + DataHolder.defaultChannel + "/" + DataHolder.defaultBandwidth);
            }
            else{
                // TODO: further check if chanspec is valid
                Nexutil.getInstance().setChanspec(chanspec[0], chanspec[1]);
                newLineToLog("Channel specs set to " + chanspecInput.getText().toString());
            }
        }

        if(labelInput.getText().toString().equals(""))
            label = "1";
        else if(labelInput.getText().toString().equals("0") || labelInput.getText().toString().equals("1"))
            label = labelInput.getText().toString();
        else {
            try{
                String colDev[] = labelInput.getText().toString().split(":");
                for(String dev : colDev)
                    collocatedDevices.add(Integer.parseInt(dev));
            }
            catch(NumberFormatException e){
                newLineToLog("Error while parsing your input of collocated devices. Input might be invalid.");
                label = "1";
            }
        }
        // TODO: possibly checks if successful
        Nexutil.getInstance().setIoctl(500, 1);
        Nexutil.getInstance().setMonitor(true);

        networkThread = new Thread(){
            @Override
            public void run(){
                try {
                    InetSocketAddress inetSocketAddress = new InetSocketAddress(InetAddress.getByName("255.255.255.255"), 5500);
                    socket = new DatagramSocket(null);
                    socket.setReuseAddress(true);
                    socket.bind(inetSocketAddress);
                    socket.setSoTimeout(120000);
                    while(DataHolder.isActive()) {
                        message = new byte[1034];
                        final DatagramPacket packet = new DatagramPacket(message, message.length);
                        socket.receive(packet);
                        socket.setSoTimeout(5000);
                        if(outputMap.containsKey(packet.getAddress().getHostAddress())){
                            outputFile = outputMap.get(packet.getAddress().getHostAddress());
                            labelFile = labelMap.get(packet.getAddress().getHostAddress());
                        }
                        else{
                            final byte[] mac = packet.getAddress().getAddress();
                            final int invNr = ((int) mac[2])*100 + ((int) mac[3]);
                            if(nameInput.getText().toString().equals("")) {
                                outputFile = new File(folder, String.format(Locale.US, "device%d_invnr%d_csi_%d-%d.txt", (int) mac[1], invNr, Calendar.getInstance().get(Calendar.HOUR_OF_DAY), Calendar.getInstance().get(Calendar.MINUTE)));
                                labelFile = new File(folder, String.format(Locale.US, "device%d_invnr%d_labels_%d-%d.txt", (int) mac[1], invNr, Calendar.getInstance().get(Calendar.HOUR_OF_DAY), Calendar.getInstance().get(Calendar.MINUTE)));
                                outputMap.put(packet.getAddress().getHostAddress(), outputFile);
                                labelMap.put(packet.getAddress().getHostAddress(), labelFile);
                            }
                            else{
                                outputFile = new File(folder, String.format(Locale.US, "%s_dev%d_invnr%d_csi_%d-%d.txt", nameInput.getText().toString(), (int) mac[1], invNr, Calendar.getInstance().get(Calendar.HOUR_OF_DAY), Calendar.getInstance().get(Calendar.MINUTE)));
                                labelFile = new File(folder, String.format(Locale.US, "%s_dev%d_invnr%d_labels_%d-%d.txt", nameInput.getText().toString(), (int) mac[1], invNr, Calendar.getInstance().get(Calendar.HOUR_OF_DAY), Calendar.getInstance().get(Calendar.MINUTE)));
                                outputMap.put(packet.getAddress().getHostAddress(), outputFile);
                                labelMap.put(packet.getAddress().getHostAddress(), labelFile);
                            }
                            runOnUiThread(new Runnable() {
                                public void run(){
                                    if(devicesInRange.getText().equals(""))
                                        devicesInRange.setText((int) mac[1] + " (" + invNr + ")");
                                    else
                                        devicesInRange.setText(devicesInRange.getText() + ", " + (int) mac[1] + " (" + invNr + ")");
                                }
                            });
                        }
                        FileWriter writer = new FileWriter(outputFile, true);
                        FileWriter labelWriter = new FileWriter(labelFile, true);
                        String sample = csiDataToSample(packet.getData());
                        writer.append(String.format("%s%n", sample));
                        writer.close();
                        if(!collocatedDevices.isEmpty()){
                            if(collocatedDevices.contains((int) packet.getAddress().getAddress()[1]))
                                label = "1";
                            else
                                label = "0";
                        }
                        labelWriter.append(String.format("%s%n", label));
                        labelWriter.close();
                        sampleCounter++;
                        if(sampleCounter<=50 || sampleCounter%500==0) {
                            newLineToLog(sampleCounter + ". sample written to file " + outputFile.getName());
                        }
                        outputFile = null;
                        labelFile = null;
                    }
                    collectionStopProcedure();
                }
                catch(SocketTimeoutException e){
                    if(DataHolder.isActive()) {
                        newLineToLog("Timeout occurred, restarting collection...");
                        runOnUiThread(new Runnable() {
                            public void run() {
                                Nexutil.getInstance().restartInterface();
                                startCsiCollection();
                            }
                        });
                    }
                    else{
                        DataHolder.setCollectionStatus(false);
                        newLineToLog("Timeout occurred: No CSI received for two minutes.");
                        collectionStopProcedure();
                    }
                }
                //TODO: Re-create initial options?
                catch (Exception e) {
                    newLineToLog("An error occurred while csi reception: " + e.getMessage());
                }
            }
        };
        networkThread.start();
    }

    private void collectionStopProcedure(){
        socket.close();
        for(File file : outputMap.values())
            MediaScannerConnection
                    .scanFile(this, new String[]{file.getAbsolutePath()},
                            new String[]{"text/plain"}, null);
        for(File file : labelMap.values())
            MediaScannerConnection
                    .scanFile(this, new String[]{file.getAbsolutePath()},
                            new String[]{"text/plain"}, null);
        runOnUiThread(new Runnable() {
            public void run(){
                Nexutil.getInstance().setIoctl(500, 0);
                Nexutil.getInstance().setMonitor(false);
                if(spinner.getSelectedItem().toString().equals("Finalize dataset")){
                    newLineToLog("Collection stopped, datasets finalized. Next run will create a new datasets");
                    outputMap.clear();
                    labelMap.clear();
                    sampleCounter = 0;
                }
                else
                    newLineToLog("Collection interrupted. Next run will extend among others" + outputFile.getName());
                collectionButton.setText("Start CSI Collection");
                collectionButton.setEnabled(true);
                changeModeButton.setEnabled(true);
                chanspecInput.setEnabled(true);
                labelInput.setEnabled(true);
                nameInput.setEnabled(true);
                spinner.setEnabled(true);
                collocatedDevices.clear();
            }
        });
    }

    private void stopCsiCollection(){
        DataHolder.setCollectionStatus(false);
        collectionButton.setEnabled(false);
    }

    private void newLineToLog(final String log){
        runOnUiThread(new Runnable() {
            public void run(){
                applicationLog.setText(applicationLog.getText() + "\n" + Calendar.getInstance().get(Calendar.HOUR_OF_DAY) + "-" + Calendar.getInstance().get(Calendar.MINUTE) + ": " + log);
            }
        });
    }

    public void onItemSelected(AdapterView<?> parent, View view, int pos, long id){
        collectionButton.setEnabled(true);
    }

    public void onNothingSelected(AdapterView<?> parent){
        collectionButton.setEnabled(false);
    }

    public void collectionButtonOnClick(View view){
        if(collectionButton.getText().equals("Start CSI Collection")){
            startCsiCollection();
        }
        else{
            stopCsiCollection();
        }
    }

    public void senderButtonOnClick(View view){
        startActivity(new Intent(this,SenderActivity.class));
    }
}
