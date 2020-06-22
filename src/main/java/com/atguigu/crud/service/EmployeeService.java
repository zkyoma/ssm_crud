package com.atguigu.crud.service;


import com.atguigu.crud.bean.Employee;

import java.util.List;

public interface EmployeeService {

    /**
     * 查询所有
     * @return
     */
    List<Employee> getAll();

    /**
     * 保存员工
     * @param employee
     */
    void saveEmp(Employee employee);

    /**
     * 判断用户名是否可用
     * 返回true：表示可用
     * 返回false：表示不可用
     * @param empName
     * @return
     */
    boolean checkUser(String empName);

    /**
     * 根据id查询用户
     * @param id
     * @return
     */
    Employee getEmp(Integer id);

    /**
     * 更新用户
     * @param employee
     */
    void updateEmp(Employee employee);

    /**
     * 根据id删除用户
     * @param id
     */
    void deleteEmpById(Integer id);

    /**
     * 根据id集合批量删除
     * @param ids
     */
    void deleteBatch(List<Integer> ids);
}
