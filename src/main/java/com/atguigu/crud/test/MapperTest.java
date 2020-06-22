package com.atguigu.crud.test;

import com.atguigu.crud.bean.Employee;
import com.atguigu.crud.dao.DepartmentMapper;
import com.atguigu.crud.dao.EmployeeMapper;
import org.apache.ibatis.session.SqlSession;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.UUID;

/**
 * Spring项目的单元测试
 * 1.导入Spring-test模块
 * 2. @ContextConfiguration指定Spring配置文件的位置
 * 3. 直接autowired要使用的组件即可
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {"classpath:applicationContext.xml"})
public class MapperTest {

    @Autowired
    private DepartmentMapper departmentMapper;
    @Autowired
    private EmployeeMapper employeeMapper;
    @Autowired
    private SqlSession sqlSession;


    @Test
    public void testCRUD(){
        //1. 插入部门
        //departmentMapper.insertSelective(new Department(null, "开发部"));
        //departmentMapper.insertSelective(new Department(null, "测试部"));
        //2. 插入员工
        //employeeMapper.insertSelective(new Employee(null, "Jerry", "M", "Jerry@guigu.com", 1));
        //3. 批量插入多个员工
        EmployeeMapper mapper = sqlSession.getMapper(EmployeeMapper.class);
        for(int i = 0; i < 1000; i++){
            String uuid = UUID.randomUUID().toString().substring(0, 5);
            mapper.insertSelective(new Employee(null, uuid, "M", uuid + "@atguigu.com", 1));
        }
    }
}
