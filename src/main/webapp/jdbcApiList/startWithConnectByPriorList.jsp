<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	// 메뉴바로 활용해서 모든 페이지 상단에 띄움
	// controller

	// model
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "HR";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	System.out.println(conn);
	
	// 페이징 변수
	int currentPage = 1;
	if (request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int rowPerPage = 10;
	if (request.getParameter("rowPerPage") != null){
		rowPerPage = Integer.parseInt(request.getParameter("rowPerPage"));
	}
	int beginRow = (currentPage - 1) * rowPerPage + 1;
	int endRow = beginRow + rowPerPage - 1;
	
	// 페이징 네비게이션
	int pagePerPage = 10;
	int beginPage = ((currentPage - 1) / pagePerPage) * pagePerPage + 1;
	int endPage = beginPage + pagePerPage - 1;
	int totalCnt = 0;
	int totalCntPage = 0;
	
	
	// pageCnt
	String totalCntSql = "SELECT count(*) cnt FROM employees";
	PreparedStatement totalCntStmt = conn.prepareStatement(totalCntSql);
	ResultSet totalCntRs = totalCntStmt.executeQuery();
	
	if(totalCntRs.next()){
		totalCnt = totalCntRs.getInt("cnt");
	}
	
	if(endRow > totalCnt) {
		endRow = totalCnt;
	}
	
	totalCntPage = (int)Math.ceil((double)totalCnt / pagePerPage);
	if (endPage > totalCntPage){
		endPage = totalCntPage;
	}
	
	System.out.println(totalCnt + " <- startWithConnectByPriorList totalCnt");
	System.out.println(totalCntPage + " <- startWithConnectByPriorList totalCntPage");
	String subSql = " (select rownum rnum, level lvl, lpad('-', level - 1, '-') || first_name firstName, manager_id managerId, SYS_CONNECT_BY_PATH(first_name, '/') sysConnectByPath from employees"
					+ " start with manager_id is null connect by prior employee_id = manager_id) ";
	String rankSql = "SELECT lvl, firstName, managerId, sysConnectByPath "
						+ "FROM" + subSql
						+ "WHERE rnum BETWEEN ? AND ? ";
	PreparedStatement rankStmt = conn.prepareStatement(rankSql);
	rankStmt.setInt(1, beginRow);
	rankStmt.setInt(2, endRow);
	System.out.println(rankStmt + " <- startWithConnectByPriorList rankStmt");
	ResultSet rankRs = rankStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> rankList = new ArrayList<HashMap<String, Object>>();
	while (rankRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("lvl", rankRs.getInt("lvl"));	
		m.put("firstName", rankRs.getString("firstName"));	
		m.put("managerId", rankRs.getString("managerId"));	
		m.put("sysConnectByPath", rankRs.getString("sysConnectByPath"));	
		rankList.add(m);
	}
	System.out.println(rankList.size() + " <- startWithConnectByPriorList rankList.size()");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link id="theme" rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
	<div>
		<jsp:include page="/jdbcApiList/menuBar.jsp"></jsp:include>
	</div>
	<h1>startWithConnectByPriorList</h1>
	<table class="table">
		<tr>
			<th>level</th>
			<th>firstName</th>
			<th>managerId</th>
			<th>sysConnectByPath</th>
		</tr>
	<%
		for(HashMap<String, Object> m : rankList){
			String lvlColor = null;
			if ((int)m.get("lvl") == 1){
				lvlColor = "table-primary";
			} else if((int)m.get("lvl") == 2){
				lvlColor = "table-secondary";
			} else if((int)m.get("lvl") == 3){
				lvlColor = "table-danger";
			} else if((int)m.get("lvl") == 4){
				lvlColor = "table-warning";
			}
	%>
			<tr class="<%=lvlColor%>">
				<td><%=m.get("lvl")%></td>
				<td><%=m.get("firstName")%></td>
				<td><%=m.get("managerId")%></td>
				<td><%=m.get("sysConnectByPath")%></td>
			</tr>
	<%
		}
	%>
	</table>
	<!-- 페이징 -->
	<table class="table">
		<tr>
	<%
		if (beginPage > 1) {
	%>
			<td>
				<a class="btn" href="<%=request.getContextPath()%>/jdbcApiList/startWithConnectByPriorList.jsp?currentPage=<%=beginPage - pagePerPage%>">
					이전
				</a>
			</td>
	<%
		}
		for (int i = beginPage; i <= endPage; i++){
			String currentClass = null;
			if (i == currentPage){
				currentClass = "btn-secondary";
			}
	%>
			<td>
				<a class="btn <%=currentClass%>" href="<%=request.getContextPath()%>/jdbcApiList/startWithConnectByPriorList.jsp?currentPage=<%=i%>">
					<%=i%>
				</a>
			</td>
	<%
			
		}
		if (endPage != totalCntPage) {
	%>
			<td>
				<a class="btn" href="<%=request.getContextPath()%>/jdbcApiList/startWithConnectByPriorList.jsp?currentPage=<%=beginPage + pagePerPage%>">
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