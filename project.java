import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * 
 * @author Riley Schmid
 *
 */
class project {
	public static String item1, item2, item3;
	private static final int standard = 1;
    public static Connection makeConnection(String port, String database, String password) {
        try {
            Connection conn = null;
            conn = DriverManager.getConnection("jdbc:mariadb://localhost:" + port+ "/" + database+"?verifyServerCertificate=false&useSSL=true", "root",password);
            System.out.println("Database " + database +" connection succeeded!");
            System.out.println();
            return conn;
        } catch (SQLException e) {
        	errorMessage(e);
        }
        return null;
    }

    public static void runGetItems(Connection conn, String code) {
    	PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            stmt = conn.prepareStatement("call GetItems(?)");
            stmt.setString(standard, code);
            rs = stmt.executeQuery();
            rs.beforeFirst();
            while (rs.next()) {
              output(rs);
            }
        } catch (SQLException e) {
        	errorMessage(e);
        } finally {
          
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException sqlEx) {
                	System.out.println(sqlEx);
                } 
                rs = null;
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException sqlEx) {
                	System.out.println(sqlEx);
                }
                stmt = null;
            }
        }
    }
    public static void runItemsAvailable(Connection conn, String code) {

        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            stmt = conn.prepareStatement("call ItemsAvailable(?)");
            stmt.setString(standard, code);
            rs = stmt.executeQuery();
            rs.beforeFirst();
            while (rs.next()) {
                output(rs);
            }
        } catch (SQLException e) {
        	errorMessage(e);
        } finally {
          
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException sqlEx) {
                	System.out.println(sqlEx);
                } 
                rs = null;
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException sqlEx) {
                	System.out.println(sqlEx);
                } 
                stmt = null;
            }
        }
    }

    public static void runQuery(Connection conn) {

        Statement stmt = null;
        ResultSet rs = null;

        try {
            stmt = conn.createStatement();
            rs = stmt.executeQuery("SELECT * FROM Item Limit 1;");
            rs.beforeFirst();
            while (rs.next()) {
            	output(rs);
            }
        } catch (SQLException e) {
           errorMessage(e);
        } finally {

        	if (rs != null) {
        		try {
        			rs.close();
        		} catch (SQLException sqlEx) {
        			System.out.println(sqlEx);
        		}
        		rs = null;
        	}
        	if (stmt != null) {
        		try {
        			stmt.close();
        		} catch (SQLException sqlEx) {
        			System.out.println(sqlEx);
        		}
        		stmt = null;
        	}
        }
    }

    public static void main(String[] args) {
        try {
        	
        	item1 = args[0];
        	item2 = args[1];
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            System.out.println();
            System.out.println("JDBC driver loaded");
            System.out.println();
            if (args.length == 0){
            	usage();
              return;
            } else if (item1.equals("/?")){
            	usage();
              return;
			} else {
                System.out.println(item1);
            }

			if (args.length == 2) {
				System.out.println(item2);
			}

            Connection conn = makeConnection("3306", "localhost","hunter2");

            if (item1.equals("GetItems"))
            {
                 System.out.println("Running GetItems");
                runGetItems(conn, item2);    
            }
            else if (args[0].equals( "ItemsAvailable") ){
                System.out.println("Running ItemsAvailable");
                runItemsAvailable(conn, item2);
            }
            else if (item1.equals( "test") ){
                 System.out.println("Running test");
                runQuery(conn);
            }
            else {
                System.out.println("No process requested");
            }
            conn.close();
            System.out.println();
            System.out.println("Database cs310project connection closed");
            System.out.println();
        } catch (Exception ex) {
            
            System.err.println(ex);
        }
    }
    
    /**
     * 
     */
    public static void usage() {
    	 System.out.println ("Usage :   GetItems code");
         System.out.println ("Usage :   ItemsAvailable code");
         System.out.println ("Usage :   test");
    }
    /**
     * 
     * @param r
     * @throws SQLException
     */
    public static void output(ResultSet r) throws SQLException {
    	System.out.println(r.getInt(1) + ":" + r.getString(2)  + ":" + r.getString(3) + ":" + r.getString(4));
    }
    
    /**
     * 
     * @param ex
     */
    public static void errorMessage(SQLException e) {
    	 System.err.println("SQLException: " + e.getMessage());
         System.err.println("SQLState: " + e.getSQLState());
         System.err.println("VendorError: " + e.getErrorCode());
    }
}

