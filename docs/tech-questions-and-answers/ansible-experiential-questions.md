
Questions for experienced ansible engineers
===

A set of more basic/academic questions and answers can be found [here](./standard-ansible-questions-and-answers.md)

### <a id="Q1"></a>Q1. Have you developed roles/modules at all?

> What is the most complex role/module you have developed? 
>   Please elaborate/describe what it did.
>
> If so, please describe scope/scale of such development.
>   E.g., how many roles/collections developed/ what is the most complex and why.
>
> What ansible role/collection would you be most proud of?  
>    E.g., what would you want to show off to others and/or the opensource community?

### <a id="Q2"></a>Q2. What is your experience with ansible execution environments? Please elaborate.

### <a id="Q3"></a>Q3. What is your level of experience with ansible-runner/ ansible-builder? Please elaborate.

### <a id="Q4"></a>Q4. Assuming you have a cluster of nodes with the same configuration, how would you store the settings for this configuration?
  
### <a id="Q5"></a>Q5. Why/when to use group_vars?

>  * Expecting to hear that this is the most usual way to store variable settings.  
>  * Ansible offers the ability to map hosts to groups in the inventory and then make use of the groups to set variable state

### <a id="Q6"></a>Q6. Why/when do you use host vars?
>  * Expecting to hear - use host vars when there is a specific need for a specific host level variable setting(s) that do not conform to a group. 

### <a id="Q7"></a>Q7. When would you need to use the 'hostvars' lookup? 

> when/why would you need to use the 'hostvars' lookup in a role?
>  Expecting to hear that this would usually get used when automating a 3rd party agent such as a controller 
>    - e.g., 
>      - usually when an intermediary agent/controller is involved
>      - e.g., vsphere, cloud-based controllers such as aws/azure/opeshift/openstack/etc

### <a id="Q8"></a>Q8. When do you usually use 'when:' conditional?

> When would you recommend to not use a 'when:' conditional and how would you replace/remove them?

### <a id="Q9"></a>Q9. When would you move code from a playbook to a role? and why?

### <a id="Q10"></a>Q10. What SW deployments have you done with ansible?  with terraform?  

> Have you done software deployments?  if so, any clustered SW? If so, please elaborate.

### <a id="Q11"></a>Q11. Have you used ansible to automate any switch configurations?

> If so, how did you establish connection to the switch? E.g. what protocol was used?  
> 
> Have you used any ansible network vendor modules (e,g, juniper/cisco/etc). 
>
> In either case, using vendor module or otherwise, please elaborate on how used ansible to config network.
> 

### <a id="Q12"></a>Q12. What is your level of experience developing in powershell?

> developing ansible roles to use powershell? Please elaborate.

### <a id="Q13"></a>Q13. Would you describe yourself as a executor or a conceptualizer? Please elaborate.

### <a id="Q14"></a>Q14. Problem solving skills. Please elaborate on method(s) to debug ansible roles.


### <a id="Q15"></a>Q15. Do you have experience with using ansible to automate windows domain controller?

> e.g., GPO/AD/windows server 

### <a id="Q16"></a>Q16. Do you have window image template experience? Please elaborate.

> Any experience in creating a vmware windows server template with paravirtual control driver?
> 
> If so, what was the process used to do this?  (it involves adding the pscsi drivers and then adding the new disk and upon starting the windows OS will automatically pick up the new controller)
> 
> In a vmware runtime setting, how would you replace the standard iscsi controller  pscsi controller - that would be very nice
>


### <a id="Q17"></a>Q17. Describe some bad usage patterns you have witnessed/experienced for ansible?  How would fix/refactor those cases?   

### <a id="Q18"></a>Q18. Conversely, describe some best practices for ansible usage?


