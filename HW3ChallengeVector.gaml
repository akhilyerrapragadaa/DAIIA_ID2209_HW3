
model HW3ChallengeVector

/*
 * 
 * This code is based on the code below with modifications:
 * https://github.com/gama-platform/gama/wiki/FIPA-Skill-FIPA-CFP-(2)
 * Our own HW2aa
 */

global {
	
	int globalDelayTime <- 50; //time before stage restarts
	int nbOfParticipants <- 20; //people should be 5
	int circleDistance <- 8; 
	list<list> participantsDecidedToJoin <- [[],[],[],[],[],[]];
	bool globalLeaderElected <- false;
	agent globalLeader;
	int distanceReceiveEnd <- 15;
		
	list<list> inform_result_participant <- [[],[],[],[],[],[]];
	list<int> numOfRefusers <- [0,0,0,0,0];
	
	
	
	
	init {		
		
		create FestivalGuest number: nbOfParticipants;
	
				
		create Stage number: 1
		{
		location <- {50,50,0};
		participantListIndex <- 0;
		//light shows, visuals, music type, space, food, drinks
		BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),0];
		}
		
		create Stage number: 1
		{
		location <- {10,10,0};
		participantListIndex <- 1;
		BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),0];
		
		}
		
		create Stage number: 1
		{
		location <- {80,80,0};
		participantListIndex <- 2;
		//BandAttributes <- [(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10)];
				BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),0];
		
		}
		
		create Stage number: 1
		{
		location <- {40,80,0};
		participantListIndex <- 3;
		//BandAttributes <- [(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10)];
				BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),0];
		
		}
		
		
				
		write 'Please step the simulation to observe the outcome in the console';
	}
}

species Stage skills: [fipa] {
	
	int startBid <- rnd(500,5000);
	int minBid <- rnd(10,(startBid/4));
	//int minBid <- startBid-100;
	bool concertHasEnded <- false;
	list<float> BandAttributes;
	bool sent_info <- false;
	bool sent_first <- false;
	
	int delayStart;
	
	int localDelayTimeBand <- rnd(120,170); //time before stage restarts
	
	int delayStartBandPlay; //start counting when sent inform
	bool delaybandOK<-true;
	
	
	bool delayOK <- true;
	bool foundMinBid <- false;
	bool is_playing <- false;
	bool resend_startinfo <-false; //for update
	

	
	int participantListIndex;	
	
	reflex mass_resend_startinfo when: resend_startinfo{
		resend_startinfo<-false;
		if(is_playing or sent_info)
		{
			
		list<agent> sendTo <- FestivalGuest where (each.is_leader=false and each.part_of_mass=false);	
		write sendTo;
		
		do start_conversation with: [ to :: list(sendTo), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("UPDATE START: "+self.name),BandAttributes,self,participantListIndex,"START","UPDATE"] ];
			
		}
	}
	
		reflex receive_cfp_when_playing when: !empty(cfps) {
		if (is_playing)
		{
		
		message proposalFromInitiator <- cfps[0];
		write '(Time ' + time + '): ' + name + ' receives a cfp message from ' + agent(proposalFromInitiator.sender).name + ' with content ' + proposalFromInitiator.contents;
		do start_conversation with: [ to :: list(agent(proposalFromInitiator.sender)), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Answer: BAND is playing at: "+self.name),BandAttributes,self,participantListIndex,"START"] ];
		
		}
	}
	
	reflex receive_mass_send when: !empty(queries) {
		
		message a <- queries[0];
		write '(Time ' + time + '): ' + name + ' receives a accept_proposal message from ' + agent(a.sender).name + ' with content ' + a.contents;
		
		string queryInfo <- a.contents[0];
		int indexTo <- a.contents[1];
		resend_startinfo<-true;
		
			/*write name+"MASS IS COMING TO ME############################################################# ------------->>>>>>>>>>>>>>>>>>>>>>>>";
			write name+"MASS IS COMING TO ME############################################################# ------------->>>>>>>>>>>>>>>>>>>>>>>>";
			write name+"MASS IS COMING TO ME############################################################# ------------->>>>>>>>>>>>>>>>>>>>>>>>";
			write name+"MASS IS COMING TO ME############################################################# ------------->>>>>>>>>>>>>>>>>>>>>>>>";
			write name+"MASS IS COMING TO ME############################################################# ------------->>>>>>>>>>>>>>>>>>>>>>>>";*/
			//write "attr "+queryInfo+" indexto: "+indexTo+"partindex "+participantListIndex;
		
		if(indexTo=participantListIndex)
		{
			write name+"GOES IN BELOW";
			
			BandAttributes[6]<-10;
		}
		else		{
			write name+"GOES IN NOT MASS";
			
			BandAttributes[6]<-0;
		}
		
		
	}
	
		
	reflex resetAttributes when: concertHasEnded 
	{
		//startBid <- rnd(500,5000);
		delayOK <- false;
		sent_info <- false;
		sent_first <- false;
		//minBid <- rnd(10,(startBid/4));
		concertHasEnded <- false;
		delayStart <- time;	
		participantsDecidedToJoin[participantListIndex] <- [];
		is_playing <- false;		
		BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),0];
		
		localDelayTimeBand <- rnd(120,170);
		
	}
	
	//Delay for time for setting up the stage for a new band	
	reflex countDelay when: !delayOK 
	{
		if((time-delayStart)>globalDelayTime)
		{
			delayOK<-true;
		}
			
	}
	
	//How long a band will play
		reflex countDelayBand when: !delaybandOK 
	{
		if((time-delayStartBandPlay)>localDelayTimeBand)
		{
			delaybandOK<-true;
			write "SEND END";
			if (length(participantsDecidedToJoin[participantListIndex])>0)
			{
			do start_conversation with: [ to :: participantsDecidedToJoin[participantListIndex], protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("END: "+self.name),BandAttributes,self,participantListIndex,"END"] ];
			
			}
			//sent_info<-false;
			is_playing<-false;
			concertHasEnded<-true;
		}
			
	}
	
	
		
	reflex send_info_to_possible_participants when: !sent_first and !sent_info and delayOK {
		
		write "firstSend"+self.name+"BandAttributes:"+BandAttributes;
		
		is_playing <- true;
		list notBusyParticipants <- (list(FestivalGuest));
		if(length(notBusyParticipants)>0)
		{
		
		write '(Time ' + time + '): ' + name + ' sends a inform message to all possible participants';
		write '(Time ' + time + '): ' + notBusyParticipants ;		
		do start_conversation with: [ to :: notBusyParticipants, protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Inform: BAND starts at: "+self.name),BandAttributes,self,participantListIndex,"START"] ];
		sent_info <- true;
		
		}
		
		//DELAY
		delayOK <- false;
		delayStartBandPlay <- time;
		delaybandOK<-false;
		
		
		
		
	}
	

	
	reflex receive_inform_messages when: !empty(informs) {
		write '(Time ' + time + '): ' + name + ' receives inform messages';
		
		loop i over: informs {
			write '\t' + name + ' receives a inform message from ' + agent(i.sender).name + ' with content ' + i.contents ;
		}
	}
	aspect base {
		draw circle((circleDistance)#m) color: #lightblue depth:1;
		draw circle(1) color: (is_playing) ? #purple : #red depth:4;
	}
}

species FestivalGuest skills: [fipa,moving] {
	
	
	bool is_leader <- false;
	bool calculatedOwnutility <- false;
		
	bool init <- false;
	bool part_of_mass <- false;
	bool likes_mass <- false;
	
	//random value of half of the first initiatior.
	bool busy <- false;
	bool gotFirstProposal <- false;
	bool goingToStage <- false;
	//list<float> utilityValues <- [(rnd(0,7)/10),(rnd(1,25)/10),(rnd(0,3)/10),(rnd(1,2)/10),(rnd(1,7)/10),(rnd(1,2)/10)];
	list<float> utilityValues <- [(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10)];
	list<float> utilityPerStage <- [0.0,0.0,0.0,0.0];
	
	
	
	float currentBestUtility <- 0.0;
	float massBestUtility <- 0.0;
	
	
	int participantListIndex;
	
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	point targetPoint <- nil;
	
	
	
		reflex initGuest when: !init 
	{
		part_of_mass <- flip(0.60);
		likes_mass <- flip(0.50);
		init <- true;
		

		if(!globalLeaderElected)
		{
			write self.name + "I am leader";
			globalLeaderElected<-true;
			globalLeader <- self;
			is_leader<- true;
			part_of_mass <- true;
			likes_mass <- flip(0.50);
			
		}
		
	}
	
	
		
    reflex beIdle when: !(busy) {
		do wander;
		}
		
	reflex moveToTarget when: targetPoint != nil
	{
		do goto target:targetPoint;
	}
	
	//to remove TargetPoint
	reflex arrivedAtStage when: goingToStage{
			if(distance_to(self,targetPoint)<1){
			
			write self.name + "At Stage";
			self.targetPoint <- nil;
			self.goingToStage <- false;
			
			}
		}
		
	reflex goBackToInitPoint when: distance_to(self,initPoint)<1 and busy{
			if(targetPoint=initPoint){
			write self.name + "At InitPoint";
			self.targetPoint <- nil;
			self.busy <- false;
			
			}
		}
		
		//RECEIVE SUGGESTIONS FROM MASS
		reflex receive_proposals_from_mass when: !empty(cfps) and is_leader and calculatedOwnutility{
			
			calculatedOwnutility <- false;
			
				loop cfp over: cfps {
					message proposalFromInitiator <- cfp;
					write '(Time ' + time + '): ' + name + ' receives a cfp message from ' + agent(proposalFromInitiator.sender).name + ' with content ' + proposalFromInitiator.contents;
					
					list<float> guestUtility <- proposalFromInitiator.contents[1];
					int stageIndex <- proposalFromInitiator.contents[2];
					
									loop i from: 0 to: (length(guestUtility)-1) { 
									utilityPerStage[i]<-utilityPerStage[i]+guestUtility[i];
									}
					
											
				}
				
				write "- - - - -  - - - - - - - - - - - -  - leader receives suggestions from MASS :";
				write "- - - - -  - - - - - - - - - - - -  - leader receives suggestions from MASS :";
				write "- - - - -  - - - - - - - - - - - -  - leader receives suggestions from MASS :";
				write "- - - - -  - - - - - - - - - - - -  - leader receives suggestions from MASS :";
				write "- - - - -  - - - - - - - - - - - -  - leader receives suggestions from MASS :"+utilityPerStage;
				write "- - - - -  - - - - - - - - - - - -  -  current highest :"+self.massBestUtility;
				
				float highest <- max(utilityPerStage); // var0 equals 100.0
				int sendIndex <- utilityPerStage index_of highest; // var1 equals 3 
				utilityPerStage <- [0.0,0.0,0.0,0.0];
				
				if(self.massBestUtility<highest)
				{
					self.massBestUtility<-highest;
					int oldIndex <- participantListIndex;
					write "- - - - - - - - - - - - - - -  leader decides to send index"+sendIndex;
					do start_conversation with: [ to :: list(FestivalGuest where (each.is_leader=false and each.part_of_mass=true)), protocol :: 'fipa-contract-net', performative :: 'accept_proposal', contents :: ['Mass go TO index:',sendIndex] ];
					
					//if(self.busy)
					//{
					remove self from: list(participantsDecidedToJoin[oldIndex]);
					//}
					participantListIndex<-sendIndex;
					self.busy <- true;	
					add self to: participantsDecidedToJoin[sendIndex];
					list<agent> stages <- list(Stage);
					
					self.targetPoint <- any_location_in(stages[participantListIndex]);
					self.targetPoint <- {(targetPoint.x-rnd(1,circleDistance/2)),(targetPoint.y-rnd(circleDistance/2)),targetPoint.z};
					self.goingToStage <- true;			
					
					//MASS IS COMING
					do start_conversation with: [ to :: list(stages), protocol :: 'fipa-contract-net', performative :: 'query', contents :: ['MASS IS COMING',participantListIndex] ];
					
					
					}
				
		
		}
		
		//USUAL FOR LEADER		
		reflex receive_startInfo_from_Stage_toLeader when: !empty(informs) and is_leader{
			
		float localmassGuestUtility <- 0.0;
		string lastMessage;
		
			
		loop inform over: informs {
			
		message informFromStage <- inform;
		write '(Time ' + time + '): ' + name + ' receives a INFORM message from ' + agent(informFromStage.sender).name + ' with content ' + informFromStage.contents;
				
		agent stage <- informFromStage.contents[2];
		list<float> stageAttributes <- informFromStage.contents[1];
		int localparticipantListIndex <- informFromStage.contents[3];
		string startOrEndMessage <- informFromStage.contents[4];
		
		// CFP TO LEADER with PROPS!!!!, wait for accept
		// LEADER LOOP THROUGH PROPS
		// SEND ACCEPT + SEND TO STAGE
		// FESTIVALGUEST receives accept and go to that place
		
		if(startOrEndMessage="START")
		{
			lastMessage <- startOrEndMessage;

		float calculateUtility <- (stageAttributes[0]*utilityValues[0])+(stageAttributes[1]*utilityValues[1])+(stageAttributes[2]*utilityValues[2])+(stageAttributes[3]*utilityValues[3])+(stageAttributes[4]*utilityValues[4])+(stageAttributes[5]*utilityValues[5]);
		//CALCULATE MASS!!!
		write name+"calculates utility with"+calculateUtility+"current utility: "+currentBestUtility;
		
		if(self.currentBestUtility<calculateUtility)
		{
			self.currentBestUtility<-calculateUtility;
			self.participantListIndex<-localparticipantListIndex;
			
		}
		
		}
		
				if(startOrEndMessage="END")
		{
			
			//write "################"+self.name+" receives end from index: "+localparticipantListIndex+"but i really belong to:"+participantListIndex;
			bool var0 <- participantsDecidedToJoin[participantListIndex] contains self; // var0 equals true 
			//write "should be false:"+var0;
			
			
			
			list<agent> allStages <- list(Stage);
			
			if((distance_to(self,allStages[localparticipantListIndex])>distanceReceiveEnd))
			{
			remove self from: participantsDecidedToJoin[localparticipantListIndex];
			}
			
			else{
			lastMessage <- startOrEndMessage;
			remove self from: participantsDecidedToJoin[participantListIndex];
			write name + ' Goes home: ';
			self.targetPoint <- self.initPoint;			
			self.goingToStage <- false;
			self.currentBestUtility<-0.0;
			self.massBestUtility<-0.0;
			self.utilityPerStage <- [0.0,0.0,0.0,0.0];
			calculatedOwnutility<-true;
			
			
			}
			
			
			
			
			
		}
		
			}
			
			//AFTER LOOP SEND INFO TO LEADER
			if(lastMessage!="END")
			{
			utilityPerStage[participantListIndex]<-self.currentBestUtility;
			calculatedOwnutility<-true;
			}
			
			
		}
	
	
		//USUAL interaction NOT PART of MASS
		reflex receive_startInfo_from_Stage_not_mass when: !empty(informs) and !part_of_mass and !is_leader{
		message informFromStage <- informs[0];
		write '(Time ' + time + '): ' + name + ' NOT MASS receives a INFORM message from ' + agent(informFromStage.sender).name + ' with content ' + informFromStage.contents;
		
		agent stage <- informFromStage.contents[2];
		list<float> stageAttributes <- informFromStage.contents[1];
		int localparticipantListIndex <- informFromStage.contents[3];
		string startOrEndMessage <- informFromStage.contents[4];
		
		
		if(startOrEndMessage="START")
		{
		
		if(length(list(informFromStage.contents))>5)
		{
			
			string isItanUpdate <- informFromStage.contents[5];
			if (isItanUpdate="UPDATE")
			{
				
				//IF I GET UPDATE FROM MASS AND AM AT MASS
				if(localparticipantListIndex=participantListIndex)
				{
				self.currentBestUtility<-0.0;
				}
			}
			
		}
		

		float calculateUtility <- (stageAttributes[0]*utilityValues[0])+(stageAttributes[1]*utilityValues[1])+(stageAttributes[2]*utilityValues[2])+(stageAttributes[3]*utilityValues[3])+(stageAttributes[4]*utilityValues[4])+(stageAttributes[5]*utilityValues[5]);
		//CALCULATE MASS!!!
		if(likes_mass)
		{
			write" "+"LIKES MASS calculateUtility:"+calculateUtility+"utility"+(stageAttributes[6]*10);
			
			calculateUtility<-calculateUtility+(stageAttributes[6]*10);
		}
		else{
			
			write" "+"DOENST LIKES MASS calculateUtility:"+calculateUtility+"utility"+(stageAttributes[6]*10);
			
			calculateUtility<-calculateUtility-(stageAttributes[6]*10);
			
		}
		write name+"calculates utility with"+calculateUtility+"current utility: "+currentBestUtility;
		
		if(self.currentBestUtility<calculateUtility)
		{
			self.currentBestUtility<-calculateUtility;
			if(self.busy)
			{
				remove self from: list(participantsDecidedToJoin[participantListIndex]);
			}
			participantListIndex<-localparticipantListIndex;
			self.busy <- true;	
			write name + ' decides to join stage at: ' + agent(informFromStage.sender).name+"loc:";
			add self to: participantsDecidedToJoin[participantListIndex];
			self.targetPoint <- any_location_in(stage);
			self.targetPoint <- {(targetPoint.x-rnd(1,circleDistance/2)),(targetPoint.y-rnd(circleDistance/2)),targetPoint.z};
			self.goingToStage <- true;			
		}
		
		}
		
				if(startOrEndMessage="END")
		{
			write name + ' Goes home: ';
			self.targetPoint <- self.initPoint;			
			self.goingToStage <- false;
			self.currentBestUtility<-0.0;
			
			//Check if someone is playing
			do start_conversation with: [ to :: list(Stage), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ['Are you playing? Send attributes'] ];
			
			
		}
		
			
			
		}
		
		reflex receive_instructions_from_leader when: !empty(accept_proposals) and part_of_mass and !is_leader {
		message a <- accept_proposals[0];
		write '(Time ' + time + '): ' + name + ' receives a accept_proposal message from ' + agent(a.sender).name + ' with content ' + a.contents;
		
		int indexToGo <- a.contents[1];
		
		int oldIndex <- self.participantListIndex;
		
			//		if(self.busy)
			//{
			write "partindex: old "+oldIndex+" "+participantsDecidedToJoin[oldIndex];
			remove self from: participantsDecidedToJoin[oldIndex];
			write "partindex: old "+oldIndex+" "+participantsDecidedToJoin[oldIndex];
			
			//}
			self.participantListIndex<-indexToGo;
			self.busy <- true;	
			//write name + ' decides to join stage at: ' + agent(informFromStage.sender).name+"loc:";
			add self to: participantsDecidedToJoin[indexToGo];
			list<agent> stages <- list(Stage);
			
			self.targetPoint <- any_location_in(stages[participantListIndex]);
			self.targetPoint <- {(targetPoint.x-rnd(1,circleDistance/2)),(targetPoint.y-rnd(circleDistance/2)),targetPoint.z};
			self.goingToStage <- true;			
		
	
		}
		

		
		
		//PART OF MASS
		reflex receive_startInfo_from_Stage when: !empty(informs) and part_of_mass{
			
		float localmassGuestUtility <- 0.0;
		string lastMessage;
		list<agent> stages <- list(Stage);
		
		list<float> voteslistVector;
		
		//list<int> votes;
		//write name+"send his vote"+vote;
		
		
		loop a_temp_var over: stages { 
			add 0 to: voteslistVector;
		}
		
		
			
		loop inform over: informs {
			
		message informFromStage <- inform;
		write '(Time ' + time + '): ' + name + ' receives a INFORM message from ' + agent(informFromStage.sender).name + ' with content ' + informFromStage.contents;
		
		
			//write '\t' + name + ' receives a refuse message from ' + agent(r.sender).name + ' with content ' + r.contents ;
		
		
		
		agent stage <- informFromStage.contents[2];
		list<float> stageAttributes <- informFromStage.contents[1];
		int localparticipantListIndex <- informFromStage.contents[3];
		string startOrEndMessage <- informFromStage.contents[4];
				
		// CFP TO LEADER with PROPS!!!!, wait for accept
		// LEADER LOOP THROUGH PROPS
		// SEND ACCEPT + SEND TO STAGE
		// FESTIVALGUEST receives accept and go to that place
		
		if(startOrEndMessage="START")
		{
		lastMessage <- startOrEndMessage;
			
			//write self.name+"loop***********"+stage.name;

		float calculateUtility <- (stageAttributes[0]*utilityValues[0])+(stageAttributes[1]*utilityValues[1])+(stageAttributes[2]*utilityValues[2])+(stageAttributes[3]*utilityValues[3])+(stageAttributes[4]*utilityValues[4])+(stageAttributes[5]*utilityValues[5]);
		//CALCULATE MASS!!!
		write name+"calculates utility with"+calculateUtility+"current utility: "+currentBestUtility;
		
		//localparticipantListIndex
		voteslistVector[localparticipantListIndex]<-voteslistVector[localparticipantListIndex]+calculateUtility;
		
		if(localmassGuestUtility<calculateUtility)
		{
			localmassGuestUtility<-calculateUtility;
			participantListIndex<-localparticipantListIndex;
			
		}
		
		}
		
				if(startOrEndMessage="END")
		{
			lastMessage <- startOrEndMessage;
			
			write "################"+self.name+" receives end from index: "+localparticipantListIndex+"but i really belong to:"+participantListIndex;
			bool var0 <- participantsDecidedToJoin[participantListIndex] contains self; // var0 equals true 
			write "should be false:"+var0;
			
			list<agent> allStages <- list(Stage);
			
			
			//WRONG END MESSAGES
			if((distance_to(self,allStages[localparticipantListIndex])>distanceReceiveEnd))
			{
			remove self from: participantsDecidedToJoin[localparticipantListIndex];
			}
			
			else{
			remove self from: participantsDecidedToJoin[localparticipantListIndex];
			write name + ' Goes home: ';
			self.targetPoint <- self.initPoint;			
			self.goingToStage <- false;
			self.currentBestUtility<-0.0;				
			}
			
			
			
		}
		
			}
			
			//AFTER LOOP SEND INFO TO LEADER
			if(lastMessage!="END")
			{
			do start_conversation with: [ to :: list(FestivalGuest where (each.is_leader=true)), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ['My best utility:',voteslistVector,participantListIndex] ];
			}
			
			
		}
		
	
	aspect base {
		//draw circle(1) color: (busy and self.targetPoint!=self.initPoint) ? ((participantListIndex=0) ? #black : ((participantListIndex=1) ? #grey : #green)) : #blue depth:1;
		draw circle(1) color: (busy and self.targetPoint!=self.initPoint and !part_of_mass) ? ( (participantListIndex=0) ? #black : ((participantListIndex=1) ? #grey : ( (participantListIndex=2) ? #green : #yellow) ) ) :  (part_of_mass ? #chocolate : #blue) depth:1;
			
		
	}
	
}

experiment test type: gui {

	output {
		display my_display type:opengl {
			species Stage aspect:base;
			species FestivalGuest aspect:base;	
			
			
			}
	}
}
