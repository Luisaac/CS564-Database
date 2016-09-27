import java.io.*;
import java.util.*;


public class CsvMod {
	public static void main(String[]args) throws IOException{
		File inF = new File("SalesFile.csv");
		Scanner in = new Scanner(inF);
		String [] attr;
		PrintWriter pw0 = new PrintWriter(new File("R0.csv"));
		PrintWriter pw1 = new PrintWriter(new File("R1.csv"));
		PrintWriter pw2 = new PrintWriter(new File("R2.csv"));
		PrintWriter pw3 = new PrintWriter(new File("R3.csv"));

		HashSet<String> store = new HashSet<>();
		HashSet<String> weekDate = new HashSet<>();
		HashSet<String> key2 = new HashSet<>();
		HashSet<String> key3 = new HashSet<>();


		while(in.hasNextLine()){
			String line = in.nextLine();
			attr = line.split(",");
			//0,5,6
			if(!store.contains(attr[0])){
				pw0.println(attr[0]+","+attr[5]+","+attr[6]);
				store.add(attr[0]);
			}
			//2,4
			if(!weekDate.contains(attr[2])){
				pw1.println(attr[2]+","+attr[4]);
				weekDate.add(attr[2]);
			}
			//0,2,7,8,9,10
			String k2 = attr[0].concat(attr[2]);
			if(!key2.contains(k2)){
				pw2.println(attr[0]+","+attr[2]+","+attr[7]+","+attr[8]+","+attr[9]+","+attr[10]);
				key2.add(k2);
			}
			//0,1,2,3
			String k3 = attr[0].concat(attr[1].concat(attr[2]));
			if(!key3.contains(k3)){
				pw3.println(attr[0]+","+attr[1]+","+attr[2]+","+attr[3]);
				key3.add(k3);
			}
		}
		pw0.close();
		pw1.close();
		pw2.close();
		pw3.close();
		in.close();

	}
}
