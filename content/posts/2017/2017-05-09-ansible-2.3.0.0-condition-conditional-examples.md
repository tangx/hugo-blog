---
date: "2017-05-09T00:00:00Z"
description: ansible 2.3.0.0 条件判断
keywords: playbook, tips
tags:
- ansible
title: ansible 2.3.0.0 条件判断
---


[ansible 2.3.0.0 条件判断](./ansible2.3.0.0_conditionals_examples.yaml)

```yaml
---

# ansible2.3.0.0_conditionals_examples.yaml
# ansible 2.3.0.0 conditionals test
#

# 
# https://gist.github.com/marcusphi/6791404

# $ cat local.hosts 
# local ansible_host=127.0.0.1 

# This has been tested with ansible 2.3.0.0 with these commands:
#   ansible-playbook -i local.hosts  ansible2.3.0.0_conditionals_examples.yaml 

# NB: The type of the variable is crucial!
# 字符串也可以作为『布尔值(bool)』进行判断，但是其值必须与布尔变量的名称相同。
# ex: 'false' - false
#     '1' -> 1


- name: Ansible Conditionals Examples
  hosts: local
  gather_facts: no
  
  # vars_files:
    # - vars.yml
  vars:
    is_true: true
    is_false: false
    
    is_true_string: 'true'
    is_false_string: 'false'
    is_other_string: 'other'
    
    is_True: True
    is_False: False
    
    is_yes: yes
    is_no: no
    
    is_on: on
    is_off: off
    
    is_1: 1
    is_0: 0
    
    is_1_string: '1'
    is_0_string: '0'
    
    
  tasks:
  
    ############################
    #  SIMPLE expressions 
    ############################
    
    - name: is_true         (true)      # OK  
      command: echo hello
      when: is_true
      
    - name: is_false        (false)     # OK
      command: echo hello
      when: is_false
      
    - name: (is_true)       (true)      # OK
      command: echo hello
      when: (is_true)
      
    - name: (is_false)      (false)     # OK
      command: echo hello
      when: (is_false)
      
    - name: not is_true     (false)     # OK
      command: echo hello
      when: not is_true
      
    - name: not is_false     (true)     # OK
      command: echo hello
      when: not is_false
      
    - name: not (is_true)    (false)    # OK
      command: echo hello
      when: not (is_true)
      
    - name: not (is_false)   (true)     # OK
      command: echo hello
      when: not (is_false)
      
    ####################################
    #  SIMPLE expressions  section 2
    ####################################

    - name: is_True             (true)    # OK
      command: echo hello
      when: is_True
    
    - name: is_False            (false)    # OK
      command: echo hello
      when: is_False
      
    - name: is_yes              (true)    # OK
      command: echo hello
      when: is_yes 
    
    - name: is_no               (false)    # OK
      command: echo hello
      when: is_no
      
    - name: is_on               (true)    # OK
      command: echo hello
      when: is_on
    
    - name: is_off              (false)    # OK
      command: echo hello
      when: is_off
      
    - name: is_1                 (true)    # OK
      command: echo hello
      when: is_1
    
    - name: is_0                 (false)    # OK
      command: echo hello
      when: is_0
      
    - name: is_1_string          (true)    # OK
      command: echo hello
      when: is_1_string
    
    - name: is_0_string          (false)    # OK
      command: echo hello
      when: is_0_string
      
    - name: is_true_string        (true)    # OK
      command: echo hello
      when: is_true_string
    
    - name: is_false_string       (false)    # OK
      command: echo hello
      when: is_false_string
      
    # - name: is_other_string      ( FAILED )    # FAILED: common string can not be conditional
      # command: echo hello
      # when: is_other_string
      
      
    ############################
    #  STRING EQUAL expressions 
    ############################
    
    - name: is_other_string == 'other'          (true)      # OK
      command: echo hello
      when: is_other_string == 'other'
      
    - name: is_other_string != 'other'          (false)     # OK
      command: echo hello
      when: is_other_string != 'other'
      
    - name: is_other_string != 'false'              (true)     # OK
      command: echo hello
      when: is_other_string != 'false'
      
      
    - name: not is_other_string == 'other'      (not true = false)     # OK
      command: echo hello
      when: not is_other_string == 'other'
      
    - name: not is_other_string != 'other'      (not false = true)      # OK
      command: echo hello
      when: not is_other_string != 'other'
      
    - name: not is_other_string == 'false'          (not false = true)      # OK
      command: echo hello
      when: not is_other_string == 'false'

      
    ############################
    #  MULTIPLE expressions 
    ############################
    
    - name: is_true and is_other_string == 'other'          ( true and true = true )        # OK
      command: echo hello
      when: is_true and is_other_string == 'other'
      
    - name: is_true or is_other_string == 'other'           ( true or true = true )         # OK
      command: echo hello
      when: is_true or is_other_string == 'other'
      
    - name: is_false and is_other_string == 'other'         ( false and true = false )      # OK
      command: echo hello
      when: is_false and is_other_string == 'other'
      
    - name: is_false or is_other_string == 'other'          ( false or true = true )        # OK
      command: echo hello
      when: is_false or is_other_string == 'other'
      
    - name: is_false or is_other_string != 'other'          ( false or false = false )      # OK
      command: echo hello
      when: is_false or is_other_string != 'other'
      
    - name: not is_false and is_other_string == 'other'     ( not false and true = true )   # OK
      command: echo hello
      when: not is_false and is_other_string == 'other'
      
    - name: not (is_false and is_other_string == 'other')   ( not ( false and true ) = true )   # OK
      command: echo hello
      when: not (is_false and is_other_string == 'other')
      
    - name: not (is_true and is_other_string == 'other')    ( not ( true and true ) = false )   # OK
      command: echo hello
      when: not (is_true and is_other_string == 'other')
      
    - name: not is_true or not is_other_string == 'other'   ( not true or not true = false )    # OK
      command: echo hello
      when: not is_true or not is_other_string == 'other'
      
    - name: (not is_true) or (not is_other_string != 'other')   ( (not true) or (not false) = true )    # OK
      command: echo hello
      when: (not is_true) or (not is_other_string != 'other') 
      
    ##################################
    #  MULTIPLE expressions FOR AND 
    ##################################
    
    - name: is_true and is_true         ( true )    # OK
      command: echo hello
      when:
        - is_true
        - is_true
        
    - name: is_true and is_false        ( false )   # OK
      command: echo hello
      when:
        - is_true
        - is_false
        
    - name: is_true and not is_false    ( true )    # OK
      command: echo hello
      when:
        - is_true
        - not is_false
        
    - name: is_false and is_false       ( false )   # OK
      command: echo hello
      when:
        - is_false
        - is_false
    
```