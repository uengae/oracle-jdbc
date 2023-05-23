<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link id="theme" rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
</head>
<body>
	<table class="table">
		<tr>
			<td>
				<a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/jdbcApiList/rankNtileList.jsp">
					rankNtileList	
				</a>
			</td>
			<td>
				<a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/jdbcApiList/existsNotExistsList.jsp">
					existsNotExistsList
				</a>
			</td>
			<td>
				<a class="btn btn-outline-primary" href="<%=request.getContextPath()%>/jdbcApiList/startWithConnectByPriorList.jsp">
					startWithConnectByPriorList
				</a>
			</td>
		</tr>
	</table>
</body>
</html>