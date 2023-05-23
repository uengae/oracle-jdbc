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
	int rowPerPage = 10;
	if (request.getParameter("rowPerPage") != null){
		rowPerPage = Integer.parseInt(request.getParameter("rowPerPage"));
	}
	// exists
	int currentPage = 1;
	if (request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int beginRow = (currentPage - 1) * rowPerPage + 1;
	int endRow = beginRow + rowPerPage - 1;
	
	// notExists
	int currentPageNotExists = 1;
	if (request.getParameter("currentPageNotExists") != null){
		currentPageNotExists = Integer.parseInt(request.getParameter("currentPageNotExists"));
	}
	
	int beginRowNotExists = (currentPageNotExists - 1) * rowPerPage + 1;
	int endRowNotExists = beginRowNotExists + rowPerPage - 1;
	
	// 페이징 네비게이션
	int pagePerPage = 10;
	
	// exists
	int beginPage = ((currentPage - 1) / pagePerPage) * pagePerPage + 1;
	int endPage = beginPage + pagePerPage - 1;
	int totalCnt = 0;
	int totalCntPage = 0;
	
	// notExists
	int beginPageNotExists = ((currentPageNotExists - 1) / pagePerPage) * pagePerPage + 1;
	int endPageNotExists = beginPageNotExists + pagePerPage - 1;
	int totalCntNotExists = 0;
	int totalCntPageNotExists = 0;
	
	
	// pageCnt
	// exists
	String subExistsSql = " (SELECT * FROM departments d WHERE d.department_id = e.department_id) ";
	String totalCntSql = "SELECT count(*) cnt FROM employees e WHERE EXISTS "
							+ subExistsSql;
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
	
	// notExists
	String totalCntNotExistsSql = "SELECT count(*) cnt FROM employees e WHERE NOT EXISTS "
									+ subExistsSql;
	PreparedStatement totalCntNotExistsStmt = conn.prepareStatement(totalCntNotExistsSql);
	ResultSet totalCntNotExistsRs = totalCntNotExistsStmt.executeQuery();
	
	if(totalCntNotExistsRs.next()){
		totalCntNotExists = totalCntNotExistsRs.getInt("cnt");
	}
	
	if(endRowNotExists > totalCntNotExists) {
		endRowNotExists = totalCntNotExists;
	}
	
	totalCntPageNotExists = (int)Math.ceil((double)totalCntNotExists / pagePerPage);
	if (endPageNotExists > totalCntPageNotExists){
		endPageNotExists = totalCntPageNotExists;
	}
	
	System.out.println(totalCnt + " <- existsNotExistsList totalCnt");
	System.out.println(totalCntNotExists + " <- existsNotExistsList totalCntNotExists");
	
	
	// exists
	// subSql안에 exists 집어넣기
	String subSql = " (SELECT employee_id, first_name, department_id, rownum rnum FROM employees e WHERE EXISTS"
						+ subExistsSql
						+ ") e ";
	String existsSql = "SELECT e.employee_id employeeId, e.first_name firstName, e.department_id departmentId "
						+ "FROM" + subSql
						+ "WHERE e.rnum BETWEEN ? AND ?";
	PreparedStatement existsStmt = conn.prepareStatement(existsSql);
	existsStmt.setInt(1, beginRow);
	existsStmt.setInt(2, endRow);
	System.out.println(existsStmt + " <- existsNotExistsList existsStmt");
	ResultSet existsRs = existsStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> existsList = new ArrayList<HashMap<String, Object>>();
	while (existsRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("employeeId", existsRs.getInt("employeeId"));	
		m.put("firstName", existsRs.getString("firstName"));	
		m.put("departmentId", existsRs.getInt("departmentId"));	
		existsList.add(m);
	}
	System.out.println(existsList.size() + " <- existsNotExistsList existsList.size()");
	
	// notExists
	String subNotSql = " (SELECT employee_id, first_name, department_id, rownum rnum FROM employees e WHERE NOT EXISTS"
						+ subExistsSql
						+ ") e ";
	String notExistsSql = "SELECT e.employee_id employeeId, e.first_name firstName, e.department_id departmentId "
						+ "FROM" + subNotSql
						+ "WHERE e.rnum BETWEEN ? AND ?";
	PreparedStatement notExistsStmt = conn.prepareStatement(notExistsSql);
	notExistsStmt.setInt(1, beginRowNotExists);
	notExistsStmt.setInt(2, endRowNotExists);
	System.out.println(notExistsStmt + " <- existsNotExistsList notExistsStmt");
	ResultSet notExistsRs = notExistsStmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> notExistsList = new ArrayList<HashMap<String, Object>>();
	while (notExistsRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("employeeId", notExistsRs.getInt("employeeId"));	
		m.put("firstName", notExistsRs.getString("firstName"));	
		m.put("departmentId", notExistsRs.getString("departmentId"));	
		notExistsList.add(m);
	}
	System.out.println(notExistsList.size() + " <- existsNotExistsList notExistsList.size()");
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
	<div class="container-fluid">
		<div class="row">
			<div class="col-md-6">
				<h1>existsList</h1>
				<table class="table">
					<tr>
						<th>employeeId</th>
						<th>firstName</th>
						<th>departmentId</th>
					</tr>
				<%
					for(HashMap<String, Object> m : existsList){
				%>
						<tr>
							<td><%=m.get("employeeId")%></td>
							<td><%=m.get("firstName")%></td>
							<td><%=m.get("departmentId")%></td>
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
							<a class="btn btn-sm" href="<%=request.getContextPath()%>/jdbcApiList/existsNotExistsList.jsp?currentPage=<%=beginPage - pagePerPage%>&currentPageNotExists=<%=currentPageNotExists%>">
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
							<a class="btn btn-sm <%=currentClass%>" href="<%=request.getContextPath()%>/jdbcApiList/existsNotExistsList.jsp?currentPage=<%=i%>&currentPageNotExists=<%=currentPageNotExists%>">
								<%=i%>
							</a>
						</td>
				<%
						
					}
					if (endPage != totalCntPage) {
				%>
						<td>
							<a class="btn btn-sm" href="<%=request.getContextPath()%>/jdbcApiList/existsNotExistsList.jsp?currentPage=<%=beginPage + pagePerPage%>&currentPageNotExists=<%=currentPageNotExists%>">
								다음
							</a>
						</td>
				<%
					}
				%>
					</tr>
				</table>
			</div>
			<div class="col-md-6">
				<h1>notExistsList</h1>
				<table class="table">
					<tr>
						<th>employeeId</th>
						<th>firstName</th>
						<th>departmentId</th>
					</tr>
				<%
					for(HashMap<String, Object> m : notExistsList){
				%>
						<tr>
							<td><%=m.get("employeeId")%></td>
							<td><%=m.get("firstName")%></td>
							<td><%=m.get("departmentId")%></td>
						</tr>
				<%
					}
				%>
				</table>
				<table class="table">
					<tr>
				<%
					if (beginPageNotExists > 1) {
				%>
						<td>
							<a class="btn btn-sm" href="<%=request.getContextPath()%>/jdbcApiList/existsNotExistsList.jsp?currentPage=<%=currentPage%>&currentPageNotExists=<%=beginPageNotExists + pagePerPage%>">
								이전
							</a>
						</td>
				<%
					}
					for (int i = beginPageNotExists; i <= endPageNotExists; i++){
						String currentClassNotExists = null;
						if (i == currentPageNotExists){
							currentClassNotExists = "btn-secondary";
						}
				%>
						<td>
							<a class="btn btn-sm <%=currentClassNotExists%>" href="<%=request.getContextPath()%>/jdbcApiList/existsNotExistsList.jsp?currentPage=<%=currentPage%>&currentPageNotExists=<%=i%>">
								<%=i%>
							</a>
						</td>
				<%
						
					}
					if (endPageNotExists != totalCntPageNotExists) {
				%>
						<td>
							<a class="btn btn-sm" href="<%=request.getContextPath()%>/jdbcApiList/existsNotExistsList.jsp?currentPage=<%=currentPage%>&currentPageNotExists=<%=beginPageNotExists + pagePerPage%>">
								다음
							</a>
						</td>
				<%
					}
				%>
					</tr>
				</table>
			</div>
		</div>
	</div>
</body>
</html>