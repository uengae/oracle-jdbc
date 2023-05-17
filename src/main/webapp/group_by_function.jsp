<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "HR";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn);
	
	// group by grouping sets
	// grouping sets() 안에 있는 속성을 각각 group by 해서 union all 한것
	String setsSql = "select department_id 부서ID, job_id 직원ID, count(*) 부서인원 from employees group by grouping sets(department_id, job_id)";
	PreparedStatement setsStmt = conn.prepareStatement(setsSql);
	System.out.println(setsStmt);
	ResultSet setsRs = setsStmt.executeQuery();

	ArrayList<HashMap<String, Object>> setsList = new ArrayList<HashMap<String, Object>>();
	
	while (setsRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("부서ID", setsRs.getInt("부서ID"));
		m.put("직원ID", setsRs.getString("직원ID"));
		m.put("부서인원", setsRs.getInt("부서인원"));
		setsList.add(m);
	}
	
	System.out.println(setsList);

	// group by rollup
	// rollup() 안에 있는 속성에서 앞에있는 속성을 기준으로 뒤에 있는 속성을 group by 한것과 앞 속성 별로 총합을 표시한것 
	String rollupSql = "select department_id 부서ID, job_id 직원ID, count(*) 부서인원 from employees group by rollup(department_id, job_id)";
	PreparedStatement rollupStmt = conn.prepareStatement(rollupSql);
	System.out.println(rollupStmt);
	ResultSet rollupRs = rollupStmt.executeQuery();

	ArrayList<HashMap<String, Object>> rollupList = new ArrayList<HashMap<String, Object>>();
	
	while (rollupRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("부서ID", rollupRs.getInt("부서ID"));
		m.put("직원ID", rollupRs.getString("직원ID"));
		m.put("부서인원", rollupRs.getInt("부서인원"));
		rollupList.add(m);
	}
	
	System.out.println(rollupList);

	// group by cube
	// cube() 확장함수는 rollup() 확장함수에서 뒤에 속성까지 group by 한것을 추가한것 
	String cubeSql = "select department_id 부서ID, job_id 직원ID, count(*) 부서인원 from employees group by cube(department_id, job_id)";
	PreparedStatement cubeStmt = conn.prepareStatement(cubeSql);
	System.out.println(cubeStmt);
	ResultSet cubeRs = cubeStmt.executeQuery();

	ArrayList<HashMap<String, Object>> cubeList = new ArrayList<HashMap<String, Object>>();
	
	while (cubeRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("부서ID", cubeRs.getInt("부서ID"));
		m.put("직원ID", cubeRs.getString("직원ID"));
		m.put("부서인원", cubeRs.getInt("부서인원"));
		cubeList.add(m);
	}
	
	System.out.println(cubeList);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>Employees table GROUP BY GROUPING SETS Test</h1>
	<table>
		<tr>
			<td>부서ID</td>
			<td>직원ID</td>
			<td>부서인원</td>
		</tr>
	<%
			for(HashMap<String, Object> m : setsList){
	%>
				<tr>
					<td><%=(Integer)(m.get("부서ID"))%></td>
					<td><%=(String)(m.get("직원ID"))%></td>
					<td><%=(Integer)(m.get("부서인원"))%></td>
				</tr>
	<%
				
			}
	%>
	</table>
	<hr>
	<h1>Employees table GROUP BY ROLLUP Test</h1>
	<table>
		<tr>
			<td>부서ID</td>
			<td>직원ID</td>
			<td>부서인원</td>
		</tr>
	<%
			for(HashMap<String, Object> m : rollupList){
	%>
				<tr>
					<td><%=(Integer)(m.get("부서ID"))%></td>
					<td><%=(String)(m.get("직원ID"))%></td>
					<td><%=(Integer)(m.get("부서인원"))%></td>
				</tr>
	<%
				
			}
	%>
	</table>
	<hr>
	<h1>Employees table GROUP BY CUBE Test</h1>
	<table>
		<tr>
			<td>부서ID</td>
			<td>직원ID</td>
			<td>부서인원</td>
		</tr>
	<%
			for(HashMap<String, Object> m : cubeList){
	%>
				<tr>
					<td><%=(Integer)(m.get("부서ID"))%></td>
					<td><%=(String)(m.get("직원ID"))%></td>
					<td><%=(Integer)(m.get("부서인원"))%></td>
				</tr>
	<%
				
			}
	%>
	</table>
</body>
</html>