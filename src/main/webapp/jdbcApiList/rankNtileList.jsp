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
	
	System.out.println(totalCnt + " <- rankNtileList totalCnt");
	System.out.println(totalCntPage + " <- rankNtileList totalCntPage");
	String subRankSql = " (SELECT first_name, salary,  rank() over(order by salary) rank, dense_rank() over(order by salary) denseRank, row_number() over(order by salary) rowNumber, ntile(10) over(order by salary) ntile FROM employees ORDER BY salary) ";
	String rankSql = "SELECT first_name firstName, salary, rank, denseRank, rowNumber, ntile "
						+ "FROM" + subRankSql
						+ "WHERE rowNumber BETWEEN ? AND ? ";
	PreparedStatement rankStmt = conn.prepareStatement(rankSql);
	rankStmt.setInt(1, beginRow);
	rankStmt.setInt(2, endRow);
	System.out.println(rankStmt + " <- rankNtileList rankStmt");
	ResultSet rankRs = rankStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> rankList = new ArrayList<HashMap<String, Object>>();
	while (rankRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("firstName", rankRs.getString("firstName"));	
		m.put("salary", rankRs.getInt("salary"));	
		m.put("rank", rankRs.getInt("rank"));	
		m.put("denseRank", rankRs.getInt("denseRank"));	
		m.put("rowNumber", rankRs.getInt("rowNumber"));
		m.put("ntile", rankRs.getInt("ntile"));
		rankList.add(m);
	}
	System.out.println(rankList.size() + " <- rankNtileList rankList.size()");
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
	<h1>rankNtileList order by salary</h1>
	<table class="table">
		<tr>
			<th>firstName</th>
			<th>salary</th>
			<th>rank</th>
			<th>denseRank</th>
			<th>rowNumber</th>
			<th>ntile</th>
		</tr>
	<%
		for(HashMap<String, Object> m : rankList){
	%>
			<tr>
				<td><%=m.get("firstName")%></td>
				<td><%=m.get("salary")%></td>
				<td><%=m.get("rank")%></td>
				<td><%=m.get("denseRank")%></td>
				<td><%=m.get("rowNumber")%></td>
				<td><%=m.get("ntile")%></td>
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
				<a class="btn" href="<%=request.getContextPath()%>/jdbcApiList/rankNtileList.jsp?currentPage=<%=beginPage - pagePerPage%>">
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
				<a class="btn <%=currentClass%>" href="<%=request.getContextPath()%>/jdbcApiList/rankNtileList.jsp?currentPage=<%=i%>">
					<%=i%>
				</a>
			</td>
	<%
			
		}
		if (endPage != totalCntPage) {
	%>
			<td>
				<a class="btn" href="<%=request.getContextPath()%>/jdbcApiList/rankNtileList.jsp?currentPage=<%=beginPage + pagePerPage%>">
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