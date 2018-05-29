package tk.barrydegraaff.kanari;


import java.text.SimpleDateFormat;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.Date;

public class Main {

    public static void main(String[] args) {
        String commandResult = "";
        String[] files;
        String[] ages;
        if (args.length != 3) {
            System.out.print("\r\n\r\nUsage: java -jar kanari.jar [path] [number of kanari files] [max age in days]\r\nExample: java -jar kanari.jar \"/srv/storage/backups/libvirt-filesystems/*/backup_kanarie.txt\" 13 8\r\n\r\n");
            throw new IllegalArgumentException("\r\n\r\nUsage: java -jar kanari.jar [path] [number of kanari files] [max age in days]\r\nExample: java -jar kanari.jar \"/srv/storage/backups/libvirt-filesystems/*/backup_kanarie.txt\" 13 8\r\n\r\n");
        }
        try {

            //verify number of kanaries
            commandResult = runCommand("/bin/ls "+args[0]);
            files = commandResult.split(";");
            if(Integer.parseInt(args[1])!=files.length) {
                System.out.print("CRITICAL: Number of kanari did not match, expected: "+args[1] +" got: "+files.length);
                throw new Exception("CRITICAL: Number of kanari did not match, expected: "+args[1] +" got: "+files.length);
            }

            //verify kanari age
            commandResult = runCommand("/bin/cat "+args[0]);
            ages = commandResult.split(";");
            Date kanariDate = null;
            Long todayMilliseconds = System.currentTimeMillis();
            Integer maxAge = (Integer.parseInt(args[2])*24*60*60*1000);//days * milliseconds per day
            Long totalAge = 0L;
            for (String age: ages) {


                SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
                kanariDate = sdf.parse(age);
                /*System.out.println(maxAge);
                System.out.println(kanariDate.getTime());
                System.out.println(todayMilliseconds);*/
                totalAge = totalAge + (todayMilliseconds - kanariDate.getTime());
                if((todayMilliseconds - kanariDate.getTime()) > maxAge) {
                    System.out.print("CRITICAL: kanari too old, max days ago expected: "+args[2] +" got date: "+age);
                    throw new Exception("CRITICAL: kanari too old, max days ago expected: "+args[2] +" got date: "+age);
                }

            }
            Long average = totalAge/Integer.parseInt(args[1]);
            average = average/1000/60/60/24;
            System.out.print("OK: got " +files.length+ " kanari average age "+average.toString() +" days\r\n");
        } catch (
                Exception e)
        {

        }
    }

    public static String runCommand(String cmd) throws Exception {
        try {
            ProcessBuilder pb = new ProcessBuilder()
                    .command("sh", "-c", cmd)
                    .redirectErrorStream(true);
            Process p = pb.start();

            BufferedReader cmdOutputBuffer = new BufferedReader(new InputStreamReader(p.getInputStream()));

            StringBuilder builder = new StringBuilder();
            String aux = "";
            while ((aux = cmdOutputBuffer.readLine()) != null) {
                builder.append(aux);
                builder.append(';');
            }
            String cmdResult = builder.toString();
            return cmdResult;

        } catch (
                Exception e)

        {
            System.out.print("CRITICAL: kanari command error: "+ e);
        }
        return "";
    }
}
