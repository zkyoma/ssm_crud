package com.atguigu.crud.controller;

import com.atguigu.crud.bean.Employee;
import com.atguigu.crud.bean.Msg;
import com.atguigu.crud.service.EmployeeService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 处理员工操作
 */
@Controller
public class EmployeeController {

    @Autowired
    private EmployeeService employeeService;

    /**
     * 删除
     * 1. 根据id单个删除
     * 2. 根据id集合批量删除
     * @param idsStr
     * @return
     */
    @RequestMapping(value = "/emp/{idsStr}", method = RequestMethod.DELETE)
    @ResponseBody
    public Msg deleteEmpById(@PathVariable String idsStr){
        if(idsStr.contains("-")){
            List<Integer> ids = new ArrayList<>();
            String[] ids_str = idsStr.split("-");
            for(String idStr : ids_str){
                Integer id = Integer.parseInt(idStr);
                ids.add(id);
            }
            employeeService.deleteBatch(ids);
        }else{
            Integer id = Integer.parseInt(idsStr);
            employeeService.deleteEmpById(id);
        }
        return Msg.success();
    }

    /**
     * 更新emp
     * @return
     */
    @RequestMapping(value = "/emp/{empId}", method = RequestMethod.PUT)
    @ResponseBody
    public Msg updateEmp(Employee employee){
        employeeService.updateEmp(employee);
        return Msg.success();
    }

    /**
     * 获取emp
     * @param id
     * @return
     */
    @RequestMapping(value = "/emp/{id}", method = RequestMethod.GET)
    @ResponseBody
    public Msg getEmp(@PathVariable Integer id){
        Employee employee = employeeService.getEmp(id);
        return Msg.success().add("emp", employee);
    }

    /**
     * 校验用户名是否可用
     * @return
     */
    @RequestMapping("/checkEmp")
    @ResponseBody
    public Msg checkEmp(@RequestParam("empName") String empName){
        String regEmpName = "(^[a-zA-Z0-9_-]{6,16}$)|(^[\\u2E80-\\u9FFF]{2,5}$)";
        if(!empName.matches(regEmpName)){
            return Msg.fail().add("msg_va", "用户名可以是6-16位英文和数字的组合或者2-5位中文");
        }
        boolean flag = employeeService.checkUser(empName);
        if(flag){
            return Msg.success().add("msg_va", "用户名可用");
        }
        return Msg.fail().add("msg_va", "用户名重复，请更换");
    }

    /**
     * 新增用户
     * @param employee
     * @param result
     * @return
     */
    @RequestMapping(value = "/emp", method = RequestMethod.POST)
    @ResponseBody
    public Msg saveEmp(@Valid Employee employee, BindingResult result){
        if(result.hasErrors()){
            //校验失败，应该返回失败信息，并在模态框进行显示
            Map<String, String> map = new HashMap<>();
            List<FieldError> fieldErrors = result.getFieldErrors();
            for(FieldError fieldError : fieldErrors){
                map.put(fieldError.getField(), fieldError.getDefaultMessage());
            }
            return Msg.fail().add("errorFields", map);
        }
        employeeService.saveEmp(employee);
        return Msg.success();
    }

    /**
     * 返回json数据
     * @return
     */
    @RequestMapping("/emps")
    @ResponseBody
    public Msg getEmpsWithJson(@RequestParam(value = "pn", defaultValue = "1")Integer pn){
        //1. 设置开始页码，以及每页大小
        PageHelper.startPage(pn, 5);
        //2. service查询
        List<Employee> emps = employeeService.getAll();
        //3. 封装到pageInfo中，传入连续显示的页数
        PageInfo<Employee> pageInfo = new PageInfo<>(emps, 5);
        return Msg.success().add("pageInfo", pageInfo);
    }

    /**
     * 查询员工数据，分页查询
     * @param model
     * @return
     */
    //@RequestMapping("/emps")
    public String getEmps(@RequestParam(value = "pn", defaultValue = "1")Integer pn, Model model){
        //1. 引入pageHelper插件
        //查询之前调用，传入页码，每页大小
        PageHelper.startPage(pn, 5);
        //2. statPage后面紧跟的这个查询就是一个分页查询
        List<Employee> emps = employeeService.getAll();
        //3. 使用pageInfo包装查询后的结果，交给页面
        //pageInfo封装了详细的信息，包括查询出来的数据，传入连续显示的页数
        PageInfo<Employee> pageInfo = new PageInfo<Employee>(emps, 5);
        model.addAttribute("pageInfo", pageInfo);
        return "list";
    }
}
