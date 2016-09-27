import java.sql.*;
import java.util.*;

public class JDBCSampling {
	public static Random rand = new Random(0);
	public static void main(String[] args) throws Exception {


		// Connnection	
		String url;	
		if(args.length!=0) url = args[0]; 
		else url = "jdbc:postgresql://stampy.cs.wisc.edu/cs564instr?sslfactory"
				+ "=org.postgresql.ssl.NonValidatingFactory&ssl";
		Connection conn = DriverManager.getConnection(url);
		// Done connection



		Scanner in = new Scanner(System.in);


		// Start
		// Accept a table name or a query
		while(true){
			boolean update = false;
			System.out.println("Enter the table name or specific query for sampling:");
			System.out.println("(You can also use query other than select)");
			String query = in.nextLine();
			query.trim();
			if(!query.contains(" ")) query = "Select * from " + query;
			String[] com = query.split(" ");
			if(!com[0].equalsIgnoreCase("select")){
				update = true;
			}
			Statement st = conn.createStatement();
			ResultSet rs = null;
			try{
				while(query.charAt(query.length()-1) == ';'){
					query = query.substring(0, query.length()-1);
				}
				if(update){
					st.executeUpdate(query+";");
					System.out.println("Succeed");
					continue;
				}
				else{
					rs = st.executeQuery(query +";");
				}
			}catch(Exception e){
				System.out.println("Invalid syntax or no such table!");
				System.out.println();
				continue;
			}


			//number of columns
			int col_count = rs.getMetaData().getColumnCount();
			//number of rows
			int N = 0;
			while (rs.next()) {
				++N;
			}

			// Ask for how many sample rows are desired, and do the simpling
			System.out.println("Enter the desired number of sample rows:");
			int n = in.nextInt();
			ArrayList<Integer> num = null;
			if(n > N){
				System.out.println("The total number of rows is " + N + "\n" + "Print all rows:");
				num = sampling(N,N);
			}
			else{
				num = sampling(n,N);
			}
			String desired = "(" + num.get(0);
			for(int i = 1; i < num.size();i++){
				desired = desired + "," + num.get(i);
			}
			desired += ")";





			// Fetch 

			String command = "select * \n" +
					"from( \n" +
					"select row_number()over() as row, *" +
					"from( \n" +
					query +
					")as a \n" +
					")as b \n" +
					"where row in" + desired + ";";

			rs = st.executeQuery(command);



			// Construct the output for user
			String row = "";
			for(int i = 2; i <= col_count+1; i++){
				row += rs.getMetaData().getColumnName(i) + "\t";
			}
			row += "\n";
			while (rs.next()) {
				for(int i = 2; i <= col_count+1; i++){
					row = row + rs.getString(i) + "\t";
				}
				row += "\n";

			}
			System.out.println(row);
			in.nextLine();


			// store the sample back in the database as a new table.
			boolean loopS = true;
			while(loopS){
				System.out.println("Do you want to store the sample into the databse? (y/n)");
				String option = in.nextLine();
				//TODO: create new table
				if(option.equals("y")){
					ResultSetMetaData md = rs.getMetaData();
					int col_num	= md.getColumnCount();




					// Create new table
					String tableName = null;
					StringBuilder s = new StringBuilder();
					if(col_num > 0){
						System.out.println("Enter the name of the new table:");
						tableName = in.nextLine();
						s.append("create table ").append(tableName).append(" (");
					}
					// skip the first column, which is column for the row number
					for(int i = 2; i <= col_num; i++){
						if(i>2) s. append(", ");
						String col_name = md.getColumnLabel(i);
						String col_type = md.getColumnTypeName(i);
						String constraints = "";

						while(col_type.charAt(col_type.length()-1)>=48 && col_type.charAt(col_type.length()-1)<=57){
							if(col_type.substring(0,col_type.length()-1).equals("float")){

								constraints = col_type.charAt(col_type.length()-1) + constraints;
							}

							col_type = col_type.substring(0, col_type.length()-1);

						}
						s.append(col_name).append(" ").append(col_type);
						if(col_type.equals("float")){
							s.append("("+constraints+")");
						}
					}
					s.append(" ); ");
					Statement st2 = conn.createStatement();
					System.out.println(s.toString());
					st2.executeUpdate(s.toString());






					// Insert all rows
					rs = st.executeQuery(command);
					Statement st3 = conn.createStatement();
					while (rs.next()){
						String insertion = "insert into " + tableName +" values (";
						for(int j = 2; j <= col_num; j++){

							insertion += "'" + rs.getString(j) + "'";
							if(j!=col_num) insertion += ",";

						}

						insertion += ");";
						st3.executeUpdate(insertion);
					}





					loopS = false;
				}

				else if(option.equals("n")){
					break;
				}
				else{
					loopS = true;
				}
			}


			// Reset the seed generator
			boolean loopR = true;
			while(loopR){
				System.out.println("Do you want to reset the random seed? (y/n)");
				String option = in.nextLine();
				if(option.equals("y")){
					System.out.println("Enter the new random seed");
					int seed = in.nextInt();
					rand.setSeed(seed);
					loopR = false;
				}
				else if(option.equals("n")){
					loopR = false;
				}
				else{
					loopR = true;
				}
			}

			// quit or continue
			boolean loopQ = true;
			while(loopQ){
				System.out.println("Do you want more samples? (y/n)");
				String option = in.nextLine();
				// More Sample
				if(option.equals("y")){
					break;
				}
				// Exit the program
				else if(option.equals("n")){
					System.out.println("Program End");

					// close up shop

					rs.close();

					st.close();

					conn.close();

					in.close();


					System.exit(0);
				}
				else{
					loopQ = true;
				}
			}
		}
	}


	public static ArrayList<Integer> sampling (int n, int N){
		int now = 1;
		ArrayList<Integer> list = new ArrayList<>();
		int t = 0;
		int m = 0;
		double U;
		while(true){
			U = rand.nextDouble();
			if((double)(N-t)*U >= n-m){
				now++;
				t++;
			}
			else{
				list.add(now);
				now++;
				m++;
				t++;
				if(m<n){
					continue;
				}
				else{
					break;
				}
			}
		}
		return list;
	}
}
