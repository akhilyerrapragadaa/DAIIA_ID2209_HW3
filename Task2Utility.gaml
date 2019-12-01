
model Task2Utility

/*
 * 
 * This code is based on the code below with modifications:
 * https://github.com/gama-platform/gama/wiki/FIPA-Skill-FIPA-CFP-(2)
 * Our own HW2
 */

global {
	
	int globalDelayTime <- 50; //time before stage restarts
	int nbOfParticipants <- 20; //people should be 5
	int circleDistance <- 8; 
	list<list> participantsDecidedToJoin <- [[],[],[],[],[],[]];
	
	
	
	//list<FestivalGuest> inform_done_participant <- [nil,nil,nil,nil,nil];
	
	list<list> inform_result_participant <- [[],[],[],[],[],[]];
	list<int> numOfRefusers <- [0,0,0,0,0];
	
	
	
	
	init {		
		
		create FestivalGuest number: nbOfParticipants;
	
				
		create Stage number: 1
		{
		location <- {50,50,0};
		participantListIndex <- 0;
				//light shows, visuals, music type, space, food, drinks
		//BandAttributes <- [(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10)];
		BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		}
		
		create Stage number: 1
		{
		location <- {10,10,0};
		participantListIndex <- 1;
		//BandAttributes <- [(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10)];
				BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		
		}
		
		create Stage number: 1
		{
		location <- {80,80,0};
		participantListIndex <- 2;
		//BandAttributes <- [(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10)];
				BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		
		}
		
		create Stage number: 1
		{
		location <- {40,80,0};
		participantListIndex <- 3;
		//BandAttributes <- [(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10)];
				BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		
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
	
	int localDelayTimeBand <- rnd(50,150); //time before stage restarts
	
	int delayStartBandPlay; //start counting when sent inform
	bool delaybandOK<-true;
	
	
	bool delayOK <- true;
	bool foundMinBid <- false;
	bool is_playing <- false;
	

	
	int participantListIndex;	
	
		reflex receive_cfp_when_playing when: !empty(cfps) {
		if (is_playing)
		{
		
		message proposalFromInitiator <- cfps[0];
		write '(Time ' + time + '): ' + name + ' receives a cfp message from ' + agent(proposalFromInitiator.sender).name + ' with content ' + proposalFromInitiator.contents;
		do start_conversation with: [ to :: list(agent(proposalFromInitiator.sender)), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("Answer: BAND is playing at: "+self.name),BandAttributes,self,participantListIndex,"START"] ];
		
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
		//inform_result_participant[participantListIndex] <- [];
		//inform_done_participant[participantListIndex] <- nil;
		delayStart <- time;	
		participantsDecidedToJoin[participantListIndex] <- [];
		//participantsDecidedToJoin_hasarrived[participantListIndex] <- [];
		//numOfRefusers[participantListIndex]<-0;
		is_playing <- false;		
		//BandAttributes <- [(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10),(rnd(1,10)/10)];
		BandAttributes <- [(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10),(rnd(1,5)/10)];
		
		localDelayTimeBand <- rnd(50,150);
		
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
	
	//random value of half of the first initiatior.
	bool busy <- false;
	bool gotFirstProposal <- false;
	bool goingToStage <- false;
	//list<float> utilityValues <- [(rnd(0,7)/10),(rnd(1,25)/10),(rnd(0,3)/10),(rnd(1,2)/10),(rnd(1,7)/10),(rnd(1,2)/10)];
	list<float> utilityValues <- [(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10),(rnd(0,5)/10)];
	
	float currentBestUtility <- 0.0;
	
	int participantListIndex;
	
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
		
	
	point targetPoint <- nil;
	
		
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
	
	
	
		reflex receive_startInfo_from_Stage when: !empty(informs) {
		message informFromStage <- informs[0];
		write '(Time ' + time + '): ' + name + ' receives a INFORM message from ' + agent(informFromStage.sender).name + ' with content ' + informFromStage.contents;
		
		agent stage <- informFromStage.contents[2];
		list<float> stageAttributes <- informFromStage.contents[1];
		int localparticipantListIndex <- informFromStage.contents[3];
		string startOrEndMessage <- informFromStage.contents[4];
		
		if(startOrEndMessage="START")
		{

		float calculateUtility <- (stageAttributes[0]*utilityValues[0])+(stageAttributes[1]*utilityValues[1])+(stageAttributes[2]*utilityValues[2])+(stageAttributes[3]*utilityValues[3])+(stageAttributes[4]*utilityValues[4])+(stageAttributes[5]*utilityValues[5]);
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
		
    //( (participantListIndex=0) ? #black : ( (participantListIndex=1) ? #grey : ( (participantsListIndex=2) ? #green : #yellow ) ))))
	
	aspect base {
		//draw circle(1) color: (busy and self.targetPoint!=self.initPoint) ? ((participantListIndex=0) ? #black : ((participantListIndex=1) ? #grey : #green)) : #blue depth:1;
		draw circle(1) color: (busy and self.targetPoint!=self.initPoint) ? ( (participantListIndex=0) ? #black : ((participantListIndex=1) ? #grey : ( (participantListIndex=2) ? #green : #yellow) ) ) :  #blue depth:1;
			
		
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
