package com.atguigu.crud.service;

import com.atguigu.crud.bean.Department;

import java.util.List;

public interface DepartmentService {

    /**
     * 查询所有的部门信息
     * @return
     */
    List<Department> getDepts();
}
