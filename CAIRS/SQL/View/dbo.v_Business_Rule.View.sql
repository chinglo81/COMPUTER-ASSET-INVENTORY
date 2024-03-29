USE [Asset_Tracking]
GO
/****** Object:  View [dbo].[v_Business_Rule]    Script Date: 10/5/2017 11:32:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















CREATE VIEW [dbo].[v_Business_Rule]
AS


select 
	br.ID as Buiness_Rule_ID,
	br.Code as Business_Rule_Code,
    br.Name as Business_Rule_Name,
    br.Description,
    br.Table_Name,
    case
		when br.Table_Name = 'CT_Asset_Disposition' then
			disp.Name
		when br.Table_Name = 'CT_Asset_Condition' then
            cond.Name
        when br.Table_Name = 'CT_Interaction_Type' then
            inter.Name
        when br.Table_Name = 'CT_Check_In_Type' then
			chktype.Name
		when br.Table_Name = 'CT_Repair_Type' then
			repairtype.Name
		when br.Table_Name = 'CT_Asset_Base_Type' then
			bt.Name
		when br.Table_Name = 'Import_Type' then
			(select name from Import_Type where id = bd.Code) --not able to left join on this because of invalid data types
		else 
			isnull(bd.Code, br.code)
    end as Name,
	bd.ID as Buiness_Detail_ID,
	bd.Code as Business_Detail_Code

from Business_Rule br
left join Business_Rule_Detail bd
	on bd.Business_Rule_ID = br.ID
left join CT_Asset_Disposition disp
    on disp.Code = bd.Code
    and br.Table_Name = 'CT_Asset_Disposition'
left join CT_Asset_Condition cond
    on cond.Code = bd.Code
    and br.Table_Name = 'CT_Asset_Condition'
left join CT_Interaction_Type inter
    on inter.Code = bd.Code
    and br.Table_Name = 'CT_Interaction_Type'
left join CT_Check_In_Type chktype
    on chktype.Code = bd.Code
    and br.Table_Name = 'CT_Check_In_Type'
left join CT_Repair_Type repairtype
    on repairtype.Code = bd.Code
    and br.Table_Name = 'CT_Repair_Type'
left join CT_Asset_Base_Type bt
	on bt.Code = bd.Code
	and br.Table_Name = 'CT_Asset_Base_Type'















GO
