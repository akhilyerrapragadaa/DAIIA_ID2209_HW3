model stage_guest

global {

   int no_of_guests <- 5;
   int globalDelayTime <- 50;
   bool flip <- false;
   int ack <-0;
  bool lock <- false;
  list<list> q <-[[]];
  list<list> sd;
  int guardID;
  int cx;
  
   point gotopoint <- nil;
   
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
    
    create guard number: 1{
    	 location <-{15,15,0};
    }
    
    }
}

species guard skills:[fipa,moving] {
	bool data <- true;
	
	bool hold <- false;
	
	list<list> qd;
	point guard_on_target <- nil;
	point start <- {15,15,0};
	
	
	reflex guard_busy when: guard_on_target != nil{
	    
		 do goto target:guard_on_target;
	}
	
	reflex receive_cfp_mesages when: !empty(cfps){
	message proposalFromfaintedguest <- cfps[0];
	point v <- 	 proposalFromfaintedguest.contents[0];
	agent g <-proposalFromfaintedguest.contents[1];
	
	add g to: q[guardID];
	
    if(!hold){
	hold <- true;
    }
    
}  
   
	reflex reach_guests when: hold {
	
	if(!lock){
	if(length(q[guardID])!=1 and length(q[guardID])!=0){
      q <- remove_duplicates(q);
    sd <- 1 among q[guardID];	
	point af <- sd;
	lock <- true;
	
	 if(!empty(q index_of af)){
	 guard_on_target <- af.location;  
	 }
}
	
	if(length(q[guardID])=1){
	q <- remove_duplicates(q);
		sd <- 1 among q[guardID];	
	  
	     point af <- sd;
	    lock <- true;
	    int ghs <- q index_of af;
	 //  write ghs;
	  if(!empty(q index_of af)){
	    guard_on_target <- af.location;
	   }
	}
	
	if(length(q[guardID])=0){
		lock <-false;
		guard_on_target <- start;
	}
	
	}
		
	}

	aspect base {
    draw square(5) color: #red ;
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
	float faintProbability <- (rnd(0,1))/100;
	bool faint <- false;
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
	point dumm;
	int battery <- rnd(1000);
    int sdf <-0;
	
	reflex beIdle when: targetPoint = nil and !faint{
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil and !faint and sdf=0
	{
	  
	    if(battery=0){
		write "*******************I'm faintinggggggg***********************" +self+"Battery about to die!"+ battery;
		self.faint <- true;
		
		}
		else{
			self.faint <- false;
		}
		
		if(self.faint){
		dumm <-self.location;
		
		do start_conversation with: [ to :: list(guard), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: [dumm,self]];
	sdf <- 1;
		}
		else{
		battery <- battery - 1;
		do goto target:targetPoint;
		}
		
	}
	
	reflex guardwithme when: !empty(guard at_distance 3) and self.faint {
	list cft;
	 sd <- remove_duplicates(sd);
	 cft <- 1 among sd;
	 bool fgt <- cft contains list(self);
	
	 if(!empty(cft) and fgt){
  
		remove self from: q[guardID];
		write "Ambulance is here";
		self.faint <- false;
		battery <-1000;
		lock <- false;
		sdf<-0;
		remove self from: sd;
		}		
	}
	
	
	reflex resetAttributes when: reset{
		stages <- [[]];
	    count <- 1;
	    i_know <- false;
	    i_now_know <- false;
	    initPoint <- {(rnd(0,100)),(rnd(0,100)),0};
	    targetPoint <- nil;
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
	    reset <- false;
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
	
	}
	
	}
	
 	  reflex send_inform_message when: !empty(stage at_distance 2) and  i_know{
	  
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
		i_know <- true;
		}
	}
		
	aspect base {
    draw square(4) color: (faint) ? #red : #blue ;
    }
}

experiment guests_stages type: gui { 
    output {
    display main_display type:opengl {
        species stage aspect: base ;
        species guest aspect: base ;
        species guard aspect: base ;
    }
    }
}
