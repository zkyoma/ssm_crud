<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>员工列表</title>
    <%
        pageContext.getServletContext().setAttribute("context", request.getContextPath());
    %>
    <script src="${context}/static/js/jquery-3.3.1.min.js"></script>
    <link href="${context}/static/bootstrap-3.3.7-dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="${context}/static/bootstrap-3.3.7-dist/js/bootstrap.min.js"></script>
    <script type="text/javascript">
        var record, currentPage;

        //1. 页面加载完成后，发送ajax请求，获得json数据
        $(function () {
            //显示第一页
            to_page(1);

            //新增按钮的单击事件，弹出模态框
            $("#emp_add_modal_btn").click(function () {
                //清除表单数据（表单重置）
                $("#empAddModal form")[0].reset();
                //显示之前清空之前的元素校验状态
                $("#empName_add_input").parent().removeClass("has-success has-error");
                $("#email_add_input").parent().removeClass("has-success has-error");
                $("#empName_add_input").next("span").text("");
                $("#email_add_input").next("span").text("");
                //发送ajax请求，查出部门信息，显示在下拉列表
                getDepts("#empAddModal select");

                //弹出模态框
                $("#empAddModal").modal({
                    backdrop:"static"
                });
            });

            $("#emp_add_btn").click(function () {
                //1. ajax校验用户名
                if($(this).attr("ajax-va") == "error"){
                    return false;
                }
                //2. 校验数据的合法性
                //前端校验
                if(!validate_add_form()){
                    return false;
                }

                //3. 发送ajax请求，保存数据
                $.ajax({
                    url:"${context}/emp",
                    type:"POST",
                    data:$("#empAddModal form").serialize(),
                    success:function (result) {
                        //alert(result.msg);
                        if(result.code == 100){
                            //成功
                            //1. 关闭模态框
                            $("#empAddModal").modal("hide");
                            //2. 发送ajax请求，来到最后一页，显示保存的信息
                            to_page(record);
                        } else {
                            //失败
                            //显示失败信息
                            var errorFields = result.extend.errorFields;
                            if(errorFields.empName != undefined){
                                //显示用户名错误信息
                                show_validate_msg("#empName_addd_input", "error", errorFields.empName);
                            }
                            if(errorFields.email != undefined){
                                // 显示邮箱错误信息
                                show_validate_msg("#email_add_input", "error", errorFields.email);
                            }
                        }
                    }
                });
            });
            
            $("#empName_add_input").change(function () {
                // if(validate_add_empName()){
                    $.ajax({
                        url:"${context}/checkEmp",
                        type:"GET",
                        data:"empName=" + $(this).val(),
                        success:function (result) {
                            if(result.code == 100){
                                //成功
                                show_validate_msg("#empName_add_input", "success", result.extend.msg_va);
                                $("#emp_add_btn").attr("ajax-va", "success");
                            }else{
                                //失败
                                show_validate_msg("#empName_add_input", "error", result.extend.msg_va);
                                $("#emp_add_btn").attr("ajax-va", "error");
                            }
                        }
                    });
                // }
            });

            //1. 给编辑按钮绑定单击事件，我们是在创建按钮之前绑定的，所以绑定不上
            //1）、可以在创建按钮时绑定    2）、绑定单击on
            $(document).on("click", ".edit_btn", function () {
                //1. 查询部门信息并显示
                getDepts("#empUpdateModal select");
                //2. 查出员工信息并显示
                getEmp($(this).attr("edit-id"));
                //3. 将id传递给修改按钮
                $("#emp_update_btn").attr("edit-id", $(this).attr("edit-id"));
                $("#empUpdateModal").modal({
                    backdrop:"static"
                });
            });

            //给更新按钮绑定单击事件，发送ajax请求进行更新
            $("#emp_update_btn").click(function () {
                //1. 首先校验邮箱格式是否正确
                if(validate_add_email("#email_update_input")){
                    $.ajax({
                        url:"${context}/emp/" + $(this).attr("edit-id"),
                        data:$("#empUpdateModal form").serialize(),
                        type:"PUT",
                        success:function () {
                            // alert(result.msg);
                            //1. 关闭模态框
                            $("#empUpdateModal").modal("hide");
                            //2. 回到本页面
                            to_page(currentPage);
                        }
                    });
                }
            });

            //给删除按钮绑定单击事件，发送ajax请求进行删除
            $(document).on("click", ".del_btn", function () {
                var empName = $(this).parents("tr").find("td:eq(2)").text();
                var empId = $(this).attr("del-id");
                if(confirm("确定要删除【" + empName + "】吗")){
                    $.ajax({
                        url:"${context}/emp/" + empId,
                        type:"DELETE",
                        success:function (result) {
                            alert(result.msg);
                            to_page(currentPage);
                        }
                    });
                }
            });

            $("#check_all").click(function () {
                //prop修改和读取dom原生属性的值
                $(".check_item").prop("checked", $(this).prop("checked"));
            });

            $(document).on("click", ".check_item", function () {
                var flag = $(".check_item:checked").length == $(".check_item").length;
                $("#check_all").prop("checked", flag);
            });

            //批量删除按钮绑定单击事件
            $("#emp_del_all_btn").click(function () {
                var empNames = "";
                var empIds = "";
                $.each($(".check_item:checked"), function () {
                    empNames += $(this).parents("tr").find("td:eq(2)").text() + "，";
                    empIds += $(this).parents("tr").find("td:eq(1)").text() + "-";
                });
                //去除多余的，
                empNames = empNames.substring(0, empNames.length - 1);
                //去除多余的-
                empIds = empIds.substring(0, empIds.length - 1);
                if(confirm("确定要删除【" + empNames + "】吗")){
                    $.ajax({
                        url:"${context}/emp/" + empIds,
                        type:"DELETE",
                        success:function (result) {
                            alert(result.msg);
                            to_page(currentPage);
                            $("#check_all").prop("checked", false);
                        }
                    });
                }
            });
        });

        //发送ajax请求查询员工信息并显示
        function getEmp(id) {
            $.ajax({
                url:"${context}/emp/" + id,
                type:"GET",
                success:function (result) {
                    //在update模态框显示用户信息
                    var empData = result.extend.emp;
                    $("#empName_update_static").text(empData.empName);
                    $("#email_update_input").val(empData.email);
                    $("#empUpdateModal input[name=gender]").val([empData.gender]);
                    $("#empUpdateModal select").val([empData.dId]);
                }
            });
        }

        //校验表单数据
        function validate_add_form() {
            return validate_add_empName() && validate_add_email("#email_add_input");
        }

        //校验用户名
        function validate_add_empName() {
            var empName = $("#empName_add_input").val();
            var regName = /(^[a-zA-Z0-9_-]{6,16}$)|(^[\u2E80-\u9FFF]{2,5}$)/;
            if(!regName.test(empName)){
                // alert("用户名可以是2-5位中文或者6-16位英文和数字的组合");
                show_validate_msg("#empName_add_input", "error", "用户名可以是2-5位中文或者6-16位英文和数字的组合");
                $("#empName_add_input").attr("empName_va", "error");
                return false;
            }
            show_validate_msg("#empName_add_input", "success", "");
            return true;
        }

        //校验email
        function validate_add_email(ele) {
            var email = $(ele).val();
            var regEmail = /^([a-z0-9_.-]+)@([\da-z.-]+)\.([a-z.]{2,6})$/;
            if(!regEmail.test(email)){
                // alert("邮箱格式不正确");
                show_validate_msg(ele, "error", "邮箱格式不正确");
                $(ele).attr("email_va", "error");
                return false;
            }
            show_validate_msg(ele, "success", "");
            return true;
        }

        //显示校验结果额提示信息
        function show_validate_msg(ele, status, msg) {
            $(ele).parent().removeClass("has-success has-error");
            $(ele).next("span").text("");
            if("success" == status){
                $(ele).parent().addClass("has-success");
            }else if("error" == status){
                $(ele).parent().addClass("has-error");
            }
            $(ele).next("span").text(msg);
        }

        //查询所有的部门信息，显示在下拉列表中
        function getDepts(ele) {
            //清空下拉列表的值
            $(ele).empty();
            $.ajax({
                url:"${context}/depts",
                type:"GET",
                success:function (result) {
                    //显示部门信息在下拉列表中
                    $.each(result.extend.depts, function () {
                        var optionEle = $("<option></option>").append(this.deptName).attr("value", this.deptId);
                        optionEle.appendTo($(ele));
                    });
                }
            });
        }

        function to_page(pn) {
            $.ajax({
                url:"${context}/emps",
                data:"pn=" + pn,
                type:"GET",
                success:function (result) {
                    //1. 解析并显示员工信息
                    build_emps_table(result);
                    //2. 解析并显示分页信息
                    build_page_info(result);
                    //3. 解析显示分页条
                    build_page_nav(result);
                }
            });
        }
        
        function build_emps_table(result) {
            //清空
            $("#emps_table tbody").empty();

            var emps = result.extend.pageInfo.list;
            $.each(emps, function (index, item) {
                var checkItemTd = $("<td><input type='checkbox' class='check_item'/></td>");
                var empIdTd = $("<td></td>").append(item.empId);
                var empNameTd = $("<td></td>").append(item.empName);
                var genderTd = $("<td></td>").append(item.gender == 'M' ? "男" : "女");
                var emailTd = $("<td></td>").append(item.email);
                var deptNameTd = $("<td><td>").append(item.department.deptName);
                var editBtn = $("<button></button>").addClass("btn btn-success btn-sm edit_btn").append(
                    $("<sapn></span>").addClass("glyphicon glyphicon-pencil")).append("编辑");
                //为编辑按钮添加自定义属性，用来存放id的值
                editBtn.attr("edit-id", item.empId);

                var delBtn = $("<button></button>").addClass("btn btn-danger btn-sm del_btn").append(
                    $("<sapn></span>").addClass("glyphicon glyphicon-trash")).append("删除");
                delBtn.attr("del-id", item.empId);
                var btnTd = $("<td></td>").append(editBtn).append(" ").append(delBtn);

                $("<tr></tr>").append(checkItemTd)
                    .append(empIdTd)
                    .append(empNameTd)
                    .append(genderTd)
                    .append(emailTd)
                    .append(deptNameTd)
                    .append(btnTd)
                    .appendTo($("#emps_table tbody"));
            })
        }

        function build_page_info(result) {
            $("#page_info_area").empty();

            var pageInfo = result.extend.pageInfo;
            $("#page_info_area").append("当前第" + pageInfo.pageNum + "页，" )
                .append("总" + pageInfo.pages + "页")
                .append("共" + pageInfo.total + "条记录");
            record = pageInfo.pages + 1;
            currentPage = pageInfo.pageNum;
        }

        function build_page_nav(result) {
            $("#page_nav_area").empty();

            var pageInfo = result.extend.pageInfo;

            //page_nav_area
            var ul = $("<ul></ul>").addClass("pagination");
            var firstPageLi = $("<li></li>").append($("<a></a>").attr("href", "#").append("首页"));
            var prePageLi = $("<li></li>").append($("<a></a>").attr("href", "#").append("&laquo;"));
            if(pageInfo.hasPreviousPage == false){
                firstPageLi.addClass("disabled");
                prePageLi.addClass("disabled");
            }else{
                firstPageLi.click(function () {
                    to_page(1);
                });
                prePageLi.click(function () {
                    to_page(pageInfo.pageNum - 1);
                });
            }
            //添加首页和上一页
            ul.append(firstPageLi).append(prePageLi);

            $.each(pageInfo.navigatepageNums, function (index, item) {
                var numLi = $("<li></li>").append($("<a></a>").attr("href", "#").append(item));
                if(pageInfo.pageNum == item){
                    numLi.addClass("active");
                }
                numLi.click(function () {
                    to_page(item);
                });
                //添加页码
                ul.append(numLi);
            });

            var nextPageLi = $("<li></li>").append($("<a></a>").attr("href", "#").append("&raquo;"));
            var lastPageLi = $("<li></li>").append($("<a></a>").attr("href", "#").append("末页"));
            if(pageInfo.hasNextPage == false){
                nextPageLi.addClass("disabled");
                lastPageLi.addClass("disabled");
            }else{
                nextPageLi.click(function () {
                   to_page(pageInfo.pageNum + 1);
                });
                lastPageLi.click(function () {
                    to_page(pageInfo.pages);
                });
            }
            //添加下一页和末页
            ul.append(nextPageLi).append(lastPageLi);
            $("<nav></nav>").append(ul).appendTo($("#page_nav_area"));
        }

    </script>
</head>
<body>

<!-- 员工新增模态框 -->
<div class="modal fade" id="empAddModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="myModalLabel">Modal title</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal">
                    <div class="form-group">
                        <label for="empName_add_input" class="col-sm-2 control-label">empName</label>
                        <div class="col-sm-10">
                            <input type="text" class="form-control" name="empName" id="empName_add_input" placeholder="empName">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="email_add_input" class="col-sm-2 control-label">email</label>
                        <div class="col-sm-10">
                            <input type="email" class="form-control" name="email" id="email_add_input" placeholder="email@atguigu.com">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="gender1_add_input" class="col-sm-2 control-label">gender</label>
                        <div class="col-sm-10">
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender1_add_input" value="M" checked="checked"> 男
                            </label>
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender2_add_input" value="F"> 女
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label" for="dept_add_select">deptName</label>
                        <div class="col-sm-4">
                            <select class="form-control" name="dId" id="dept_add_select"></select>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="emp_add_btn">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 员工更新模态框 -->
<div class="modal fade" id="empUpdateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            </div>
            <div class="modal-body">
                <form class="form-horizontal">
                    <div class="form-group">
                        <label for="empName_add_input" class="col-sm-2 control-label">empName</label>
                        <div class="col-sm-10">
                            <p class="form-control-static" id="empName_update_static"></p>
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="email_add_input" class="col-sm-2 control-label">email</label>
                        <div class="col-sm-10">
                            <input type="email" class="form-control" name="email" id="email_update_input" placeholder="email@atguigu.com">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="gender1_add_input" class="col-sm-2 control-label">gender</label>
                        <div class="col-sm-10">
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender1_update_input" value="M" checked="checked"> 男
                            </label>
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender2_update_input" value="F"> 女
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label" for="dept_add_select">deptName</label>
                        <div class="col-sm-4">
                            <select class="form-control" name="dId" id="dept_update_select"></select>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="emp_update_btn">更新</button>
            </div>
        </div>
    </div>
</div>

<%--搭建显示页面--%>
<div class="container">
    <%--标题--%>
    <div class="row">
        <div class="col-md-12">
            <h1>SSM_CRUD</h1>
        </div>
    </div>
    <%--按钮--%>
    <div class="row">
        <div class="col-md-4 col-md-offset-8">
            <button class="btn btn-primary" id="emp_add_modal_btn">新增</button>
            <button class="btn btn-danger" id="emp_del_all_btn">删除</button>
        </div>
    </div>
    <%--表格数据--%>
    <div class="row">
        <div class="col-md-12">
            <table class="table table-hover" id="emps_table">
                <thead>
                    <tr>
                        <th><input type="checkbox" id="check_all"/></th>
                        <th>#</th>
                        <th>empName</th>
                        <th>gender</th>
                        <th>email</th>
                        <th>deptName</th>
                        <th>操作</th>
                    </tr>
                </thead>

                <tbody></tbody>
            </table>
        </div>
    </div>
    <%--分页信息--%>
    <div class="row">
        <%--分页文字信息--%>
        <div class="col-md-6" id="page_info_area"></div>

        <%--分页条信息--%>
        <div class="col-md-6" id="page_nav_area"></div>
    </div>
</div>
</body>
</html>
