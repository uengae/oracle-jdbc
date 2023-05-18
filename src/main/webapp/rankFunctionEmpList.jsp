<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	// controller
	int currentPage = 1;
	if (request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	// model
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "HR";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn);
	
	// 페이징용 총계
	String totalCntSql = "select count(*) cnt from employees";
	PreparedStatement totalCntStmt = conn.prepareStatement(totalCntSql);
	ResultSet totalCntRs = totalCntStmt.executeQuery();
	int totalCnt = 0;
	if(totalCntRs.next()){
		totalCnt = totalCntRs.getInt("cnt");
	}
	
	// 페이징 변수
	int rowPerPage = 10;
	int beginRow = (currentPage - 1) * rowPerPage + 1;
	int endRow = beginRow + rowPerPage - 1;
	if (endRow > totalCnt) {
		endRow = totalCnt;
	}
	int pagePerPage = 3;
	int totalCntPage = (int)Math.ceil((double)totalCnt / rowPerPage);
	int beginPage = ((currentPage - 1) / pagePerPage) * pagePerPage + 1;
	int endPage = beginPage + pagePerPage - 1;
	if (endPage > totalCntPage) {
		endPage = totalCntPage;
	}
	
	// 데이터 출력
	String rankSubSql = "select employee_id 직원ID, last_name 직원이름, salary 연봉, rownum rnum, rank() over(order by salary desc) 연봉순위 from employees";
	String rankMainSql = "Select 직원ID, 직원이름, 연봉, 연봉순위 from (" + rankSubSql + ") where rnum between ? and ?";
	PreparedStatement rankStmt = conn.prepareStatement(rankMainSql);
	rankStmt.setInt(1, beginRow);
	rankStmt.setInt(2, endRow);
	ResultSet rankRs = rankStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> rankList = new ArrayList<>();
	while (rankRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("직원ID", rankRs.getInt("직원ID"));
		m.put("직원이름", rankRs.getString("직원이름"));
		m.put("연봉", rankRs.getInt("연봉"));
		m.put("연봉순위", rankRs.getInt("연봉순위"));
		rankList.add(m);
	}
	System.out.println(rankList.size() + " <- rankList.size()");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link id="theme" rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
	<h1>rankFunctionEmpList</h1>
	<!-- 데이터 출력 -->
	<table>
		<tr>
			<th>직원ID</th>
			<th>직원이름</th>
			<th>연봉</th>
			<th>연봉순위</th>
		</tr>
	<%
		for(HashMap<String, Object> m : rankList){
	%>
			<tr>
				<td><%=(Integer)(m.get("직원ID"))%></td>
				<td><%=(String)(m.get("직원이름"))%></td>
				<td><%=(Integer)(m.get("연봉"))%></td>
				<td><%=(Integer)(m.get("연봉순위"))%></td>
			</tr>
	<%
		}
	%>
	</table>
	<!-- 페이징 -->
	<table>
		<tr>
	<%
			if (beginPage != 1){
	%>
				<td>
					<a class="btn" href="<%=request.getContextPath()%>/rankFunctionEmpList.jsp?currentPage=<%=beginPage - pagePerPage%>">
						이전
					</a>
				</td>
	<%
			}
			for (int i = beginPage; i <= endPage; i++){
				String currentPageBg = null;
				if (i == currentPage){
					currentPageBg = "btn-primary";
				}
	%>
				<td>
					<a class="btn <%=currentPageBg%>" href="<%=request.getContextPath()%>/rankFunctionEmpList.jsp?currentPage=<%=i%>">
						<%=i%>
					</a>
				</td>
	<%
			}
			if (endPage != totalCntPage){
	%>
				<td>
					<a class="btn" href="<%=request.getContextPath()%>/rankFunctionEmpList.jsp?currentPage=<%=beginPage + pagePerPage%>">
						다음
					</a>
				</td>
	<%
			}
	%>
		</tr>
	</table>
</body>
</html>