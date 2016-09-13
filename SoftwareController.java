package com.cisco.irt.controller.software;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.drools.runtime.process.ProcessInstance;
import org.jbpm.task.query.TaskSummary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.cisco.irt.bpmn.util.BPMNHumanTaskUtil;
import com.cisco.irt.bpmn.util.BPMNVariableLogUtil;
import com.cisco.irt.exception.TaskHandlerException;
import com.cisco.irt.form.action.impl.software.ImageList;
import com.cisco.irt.form.action.impl.software.ShrImageIosListFormAction;

/**
 *
 * @author himsriva,ahajeri
 *
 */
@Controller
public class SoftwareController {
	private static final Logger logger = Logger.getLogger(SoftwareController.class);
	
	private static final String createNonIosPostingId = "com.cisco.irt.software.E2EReleaseFlow.v1";
	
	@Autowired
	private BPMNHumanTaskUtil bpmnHumanTaskUtil;
	

	@Autowired
	private BPMNVariableLogUtil bpmnVariableLogUtil;

	@RequestMapping(value = "/software/imageList", method = RequestMethod.GET)
	public String displayImageList( HttpServletRequest request, ModelMap model) throws TaskHandlerException {
		
		System.out.println("inside software controller");
		request.setAttribute("targetForm", "upgradePlanner"); /*Added by bhargav*/
		ImageList i = new ImageList();
		return i.renderTaskForm(request, model);
	}
	
	/*@RequestMapping(value = "/software/UpgradePlanner/", method = RequestMethod.GET)
	public String displayUpgradegradePlanner( HttpServletRequest request, ModelMap model) throws TaskHandlerException {

	System.out.println("inside UpgradePlanner");
	//request.setAttribute("targetForm", "imageList");
	ImageList i = new ImageList();
	System.out.println("Created CreateReleaseDummy object");
	return i.renderTaskForm(request, model);
	}*/
	
	 /*bhargav 10/5/2014*/
	/*@RequestMapping(value = "/software/upgradePlanner", method = RequestMethod.GET)
	public String displayImageList( HttpServletRequest request, ModelMap model) throws TaskHandlerException {
		
		System.out.println("inside software controller");
		request.setAttribute("targetForm", "imageList");
		ImageList i = new ImageList();
		return i.renderTaskForm(request, model);
	}*/
	
	@RequestMapping(value = "/software/shrImageList", method = RequestMethod.GET)
	public String displayShrImageList( HttpServletRequest request, ModelMap model) throws TaskHandlerException {
		
		System.out.println("inside software controller");
		request.setAttribute("targetForm", "imageList");
		ShrImageIosListFormAction sa = new ShrImageIosListFormAction();
		return sa.renderTaskForm(request, model);
	}
	
	@RequestMapping(value = "/software/shrAddImage", method = RequestMethod.GET)
	public String displayShrAddImage( HttpServletRequest request, ModelMap model) throws TaskHandlerException {
		return "posting/jsp/addImageIos";
	}
	
	@RequestMapping(value = "/software/shrPlatformList", method = RequestMethod.GET)
	public String displayShrPlatform( HttpServletRequest request, ModelMap model) throws TaskHandlerException {
		return "posting/jsp/listPlatform";
	}
	
	@RequestMapping("/software/create")
	public  @ResponseBody Map<String, Object> createSoftware(HttpServletRequest request, ModelMap model) {
		Map<String, Object> processVariables = new HashMap<String, Object>();
		String user = request.getRemoteUser();

		Map<String, Object> results = new HashMap<String, Object>();
		results.put("status", "success");
		results.put("message", "Feature Creation Successful.");

		String currentRole = (String)request.getSession().getAttribute("currentRole");
		if (currentRole == null){
			results.put("status", "error");
			results.put("message", "Failed to access current role.");
			return results;
		}
		int osTypeId = new Integer(request.getParameter("osTypeIdStr"));
		String osTypeIdStr = (String)request.getParameter("osTypeIdStr");
		String osTypeName= (String)request.getParameter("osTypeName") ;
		String hasPlatform = (String)request.getParameter("hasPlatform");
		String hasFeatureSet= (String)request.getParameter("hasFeatureSet") ;
		String hasProductization= (String)request.getParameter("hasProductization");

	//	Integer osTypeId = new Integer(osTypeId1);
		System.out.println("******osTypeId in createSoftware==== "+osTypeId);
		System.out.println("******osTypeIdStr in createSoftware==== "+osTypeIdStr);
		System.out.println("******osTypeIdNAME in createSoftware==== "+osTypeName);
		System.out.println("******hasPlatform in createSoftware==== "+hasPlatform);
		System.out.println("******hasFeatureSet in createSoftware==== "+hasFeatureSet);
		System.out.println("******hasProductization in createSoftware==== "+hasProductization);


		//New process variables for consolidated flow.
		processVariables.put("primaryRole", currentRole);
		processVariables.put("actorId", user);
//		processVariables.put("osTypeId", 118);
		processVariables.put("osTypeId", osTypeId);
		processVariables.put("osTypeIdStr", osTypeIdStr);
		processVariables.put("osTypeName", osTypeName);
//		processVariables.put("releaseNumberId", 108801);
//		processVariables.put("releaseName", "70.1.9");
//		processVariables.put("displayId", "70.1.9");
//		processVariables.put("hasPlatform", "Y");
		processVariables.put("hasFeatures", "N");
		processVariables.put("hasPlatform", hasPlatform);
		processVariables.put("systemId", "-9999999999");
		processVariables.put("displayId", "Create Release");
//		processVariables.put("hasFeatureSet", "Y");
		processVariables.put("hasProductization", "N");
		processVariables.put("hasFeatureSet", hasFeatureSet);
//		processVariables.put("needGuestApproval", "Y");
		System.out.println("******processVariables==== "+processVariables);
		ProcessInstance processInstance = bpmnHumanTaskUtil
				.startProcess(createNonIosPostingId, processVariables);


		TaskSummary firstHumanTask = bpmnHumanTaskUtil.getNextAvailableTaskForUserInProcess(processInstance.getId(), user,(String)currentRole);
		if (firstHumanTask != null){
			results.put("nextTaskId",firstHumanTask.getId());
			String nextTaskName = bpmnHumanTaskUtil.getTaskDisplayName(firstHumanTask.getId());
			results.put("nextTaskName",nextTaskName);
			String nextTaskDisplayId = firstHumanTask.getDescription();
			results.put("nextTaskDisplayId", nextTaskDisplayId);
		}

		return results;
	}
	
	@RequestMapping(value = "/software/platformMdfPopUp/{osTypeId}/{releaseNumberId}", method = RequestMethod.GET)
	public String displayPlatformMdfPopUp( HttpServletRequest request, ModelMap model, @PathVariable("osTypeId") final Long osTypeId, @PathVariable("releaseNumberId") final Long releaseNumberId) throws TaskHandlerException {
		System.out.println("inside software controller" + releaseNumberId);
		request.setAttribute("osTypeId", osTypeId);
		request.setAttribute("releaseNumberId", releaseNumberId);
		//request.setAttribute("targetForm", "platformMdfPopUp");
		return "posting/jsp/PlatformMdfPopup";
	}
	
	@RequestMapping(value = "/software/mdfPopUp",params={"osTypeId", "hiddenMdfIdEname", "hiddenMdfNameEname"}, method = RequestMethod.GET)
	public String displayMdfPopUp( HttpServletRequest request, ModelMap model, @RequestParam(value = "osTypeId", required = false) final Long osTypeId ,@RequestParam(value = "hiddenMdfIdEname", required = false) final String hiddenMdfIdEname,@RequestParam(value = "hiddenMdfNameEname", required = false) final String hiddenMdfNameEname) 
			
			throws TaskHandlerException {
		System.out.println("inside software controller" + osTypeId);
		System.out.println("inside software controller" + hiddenMdfIdEname);
		System.out.println("inside software controller" + hiddenMdfNameEname);
		request.setAttribute("osTypeId", osTypeId);
		request.setAttribute("hiddenMdfIdEname", hiddenMdfIdEname);
		request.setAttribute("hiddenMdfNameEname", hiddenMdfNameEname);
		
		return "posting/jsp/MdfTreePost"; /*Change to MdfTreePost*/
	}
	
	
	
	@RequestMapping(value = "/software/relatedSoftwarePopUp/", method = RequestMethod.GET)
	public String displayRelatedSoftwarePopUp( HttpServletRequest request, ModelMap model) throws TaskHandlerException {
		return "posting/jsp/RelatedSoftwareMDF";
	}
}
