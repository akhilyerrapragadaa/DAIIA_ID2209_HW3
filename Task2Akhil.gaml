model stage_guest

global {
  //list<list> guests <- [[]];
   int no_of_guests <- 5;
   int globalDelayTime <- 50;
   bool flip <- false;
  // bool sent <-false;
   int ack <-0;
//   int i <- 0; 
   
   list<point> pointss <- [{50,25,0},{30,75,0},{70,75,0}];

    init {
    create stage number: 1 {
    
    location <-{30,25,0};
    }
    
    
    create stage number: 1 {
    location <-{30,75,0};
    }
    
   
    create stage number: 1 {
    location <-{70,75,0};
    }
    
    create stage number:1{
    location <-{70,25,0};
    }
    
   create guest number: no_of_guests;
    }
}

species stage skills:[fipa] {
	list<list> guests <- [[]];
	bool change <- false;
	 bool start <- true;
	float stagelightshow <- (rnd(0,10))/100;
	float stagespeakers <- (rnd(0,10))/100;
	float stageband <- (rnd(0,10))/100;
	float stagecelebfame <- (rnd(0,10))/100;
	float stagemusictypes <- (rnd(0,10))/100;
	float stageresources <- (rnd(0,10))/100;
	int stageID;
	int guestID;	
	int delayStart;
	bool delayOK <- true;
	
	
	reflex setAttributes when: change  {
	 guests <- [[]];
	 change <- false;
	 start <- true;
	 stageID <- 0;
	 guestID <- 0;	
	 stagelightshow <- (rnd(0,10))/100;
	 stagespeakers <- (rnd(0,10))/100;
	 stageband <- (rnd(0,10))/100;
	 delayStart <- time;	
	 change<-false;
	 flip <- false;
}
	
	reflex reset_attributes when: flip {
	   change <- true;	
	}
		
   reflex send_inform_message when:start{
	   do start_conversation with: [ to :: list(guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self,stageID,self.location] ];
	   start <- false;
	}
	
   	reflex receive_inform_messages when: !empty(informs) and  !start and !empty(guest at_distance 1){
		 write "Here is what we provide: LightShow- "+stagelightshow +" Speakers- "+stagespeakers + " Band- " +stageband +" CelebFame- "+stagecelebfame+" MusicTypes- "+stagemusictypes+" Resources- "+stageresources;
		message informFromParticipant <- informs[0];
		agent uniq <- informFromParticipant.contents[0];
		guestID <- informFromParticipant.contents[1];
		//sent <- true;
		do start_conversation with: [ to :: list(uniq), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [stagelightshow,stagespeakers,stageband,self,self.location,stagecelebfame,stagemusictypes,stageresources]];
	}
	
	reflex receive_refuse_messages when: !empty(refuses) {
	
		loop r over: refuses {
		write '\t' + name + ' receives a refuse message from ' + agent(r.sender).name + ' with content ' + r.contents ;
		}
	}
	
	reflex receive_propose_messages when: !empty(proposes) {
		
		loop p over: proposes {
		write '\t' + name + ' receives a propose message from ' + agent(p.sender).name + ' with content ' + p.contents ;
		}	
	}
	
	aspect base {
    draw rectangle(13,5) color: #black ;
    }
}

species guest skills:[moving,fipa] {
	list<list> stages <- [[]];
	int count <- 1;
	bool i_know <- false;
	bool i_now_know <- false;
	point initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	point targetPoint <- nil;
	float lightshow <- (rnd(0,10))/100;
	float speakers <- (rnd(0,10))/100;
	float band <- (rnd(0,10))/100;	
	float celebfame <-(rnd(0,10))/100;
	float musictypes <- (rnd(0,10))/100;
	float resources <- (rnd(0,10))/100;
	float dummy<-0.0;
	int stageID ;
	float total <- 0.0;
	agent MIB;
	int i <-1;
	int incre <-0;
	int guestID;
	agent randomguest;
	list<list> m;
	list<list> ns <- [[]];
	point mg;
	bool reset <- false;
	bool clutch <- true;
	
	reflex beIdle when: targetPoint = nil {
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil
	{
		do goto target:targetPoint;
	}
	
	reflex resetAttributes when: reset{
		stages <- [[]];
	    count <- 1;
	    i_know <- false;
	    i_now_know <- false;
	    initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	    targetPoint <- nil;
	 //   lightshow <- (rnd(0,10))/100;
	  //  speakers <- (rnd(0,10))/100;
	   // band <- (rnd(0,10))/100;	
	    dummy<-0.0;
	    stageID <- 0;
	    total <- 0.0;
	    MIB <- nil;
	    i <-1;
	    incre <-0;
	    guestID <-0;
	    randomguest <- nil;
	    m <- nil;
	    ns <- [[]];
	    mg <- nil;
	    reset <- false;
	    clutch <- true;
	} 
	
	
	reflex receive_cfp_from_stages when: !empty(cfps) and i_now_know  {		
  
    message proposalFromstage <- cfps[0];
    float theirlightshow <- proposalFromstage.contents[0];
    float theirspeakers <- proposalFromstage.contents[1];
    float theirband <- proposalFromstage.contents[2];
    agent random <- proposalFromstage.contents[3];
    point b <- proposalFromstage.contents[4];
    float theircelebfame <- proposalFromstage.contents[5];
    float theirstagemusic <- proposalFromstage.contents[6];
    float theirresources <- proposalFromstage.contents[7];
   write "Looks cool! I need: LightShow- "+lightshow +" Speakers- "+speakers + " Band- "+band +" CelebFame- "+celebfame+" MusicType- "+musictypes+" Resources- "+resources;
    total <- ((theirlightshow*lightshow) + (theirspeakers*speakers) + (band*theirband) + (celebfame*theircelebfame) + (musictypes*theirstagemusic) +(theirresources*resources));
    write "So!!! that sums up to " +total ;
    if(length(stages[stageID])!=0 and clutch){
    if(total > dummy){
    	dummy <- total;
    	MIB <-random;
    	if(i!=0){
    		ns <- [[]];
    		//write MIB;
    		add MIB to: ns[guestID];
    	}
    	
    	remove random from: stages[stageID];
    	do refuse with: [ message :: proposalFromstage, contents :: ['MMM....Interesting!'] ];
    	if(length(stages[stageID])!=0){
    	 m <- 1 among stages[stageID];
    	  mg <-m;
		 targetPoint <- any_location_in(mg.location); 
    	 i_know <- true;
    	 }
    	 else{
    	// write "I'm done!";
        m <- 1 among ns[guestID];
    	mg <-m;
		targetPoint <- any_location_in(mg.location);
		i_know <- true;
		clutch <- false;
    	 }    	
    }
    else{
    	remove random from: stages[stageID];
    	do refuse with: [ message :: proposalFromstage, contents :: ['Maybe not what I am looking for! TACK!'] ];
       if(length(stages[stageID])!=0){
       if(length(stages[stageID])!=1){
    	 m <- 1 among stages[stageID];
    	 }
    	 else{
    	 	m <- stages[stageID];
    	 }
    	mg <-m;
		targetPoint <- any_location_in(mg.location); 
    	i_know <- true;	
    	}
    	else{
      //  write "I'm done!1";
        m <- 1 among ns[guestID];
    	mg <-m;
		targetPoint <- any_location_in(mg.location); 
    	i_know <- true;
    	clutch <- false;
    	}
    }
    }
    else{
		do propose with: [ message :: proposalFromstage, contents :: ['YAYYY!! Letz partyy!!!'] ];
    	//sent <- false;
    	count <- count - 1;
        ack <- ack +1;
        if(ack = no_of_guests){
    	flip<-true;
    	ack <-0;
    }
    	reset <- true;
    	targetPoint <- nil;
    }
    
	if(count =1){
	i_now_know <- false;
	i_know<-true;
	//sent <- false;
	}
	
	}
	
 	  reflex send_inform_message when: !empty(stage at_distance 2) and  i_know{
	 // write "sent";
	  
	   do start_conversation with: [ to :: list(m[stageID]), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self,guestID] ];
	   i_know <- false;
	   i_now_know <- true;
	}
	
	
	reflex receive_inform_messages when: !empty(informs) {

		message informFromInitiator <- informs[0];
		write "Yayyy!! come visit "+ informFromInitiator.contents[0];
	 	agent randomguest <- informFromInitiator.contents[0];
		stageID <- informFromInitiator.contents[1];
		point a <- informFromInitiator.contents[2];
		
		add randomguest to: stages[stageID];
		if(length(stages[stageID])=3){
	    m <- 1 among stages[stageID];
	   	mg <-m;
		targetPoint <- any_location_in(mg.location);      
		//write targetPoint;
		i_know <- true;
		}
	}
		
	aspect base {
    draw square(4) color: #blue ;
    }
}

experiment guests_stages type: gui { 
    output {
    display main_display type:opengl {
        species stage aspect: base ;
        species guest aspect: base ;
    }
    }
}
