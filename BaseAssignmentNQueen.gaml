model queen_baseasshw3

/*
 Based on the following sources with modifications:
 * https://www.youtube.com/watch?v=0DeznFqrgAI&t=179s
 * https://en.wikipedia.org/wiki/Eight_queens_puzzle
 * https://www.geeksforgeeks.org/n-queen-problem-backtracking-3/s
 */

global {
	//14 takes 2569 cycles 16, 10000 , 18 - 40000
    int n_queens_init <- 12;
    int N_ofqueens_andBlocks <- 12; //4x4
    bool createBoard <- false;
    list<list> globalBoard;
    list<board_cell> listcells;
    int initPlaceCounter <- 0;
    
    init {
    create queen number: n_queens_init ;
    }
}

species queen skills: [fipa]{
    float size <- 1.0 ;
    rgb color <- #blue;
    board_cell my_cell <- one_of (board_cell) ;
    int lastRow <-0; //we continue from here if we receive message from successor to move.
    bool placedOnce <- false;
    int firstCol<-0;
    
    bool firstAgent <- false;
    bool firstAgent_do_once <- false;
    
        
    init {
    location <- my_cell.location;
    location <- {initPlaceCounter,0,0};
    initPlaceCounter<-initPlaceCounter+10;
    	if(!createBoard)
    	{
    		
    		listcells <- list(board_cell);
    		
    		createBoard<-true;
    						
				int indexCounter<-0;
				
				loop i from: 0 to: (N_ofqueens_andBlocks-1) { 
					add [] to: globalBoard;
					
					loop j from: 0 to: (N_ofqueens_andBlocks-1) {
						add 0 to: globalBoard[i];
						//write "indexcounter: "+indexCounter;
						//indexCounter<-indexCounter+1;
						
					} 
				} 
				
				write "GLBOAboardL:"+globalBoard;	
				firstAgent <- true;
    	}
    
    
    }
    	
    	reflex firstAgentInit when: firstAgent and !firstAgent_do_once{
    		firstAgent_do_once <- true;
    		
				list<queen> agentsL <- list(queen);
				write "-----agentsL: "+agentsL;
				int indexOfSelf <- agentsL index_of self;
				
												
				if(placeQueen(firstCol))
				{
				write "Succeeded Placing Queen: "+indexOfSelf;
				
				do start_conversation with: [ to :: list(agents[indexOfSelf+1]), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("You should place from "+self.name),"Place",self,(firstCol+1)] ];
				}
				else{
				write "Failed placing Queen: "+indexOfSelf;
				}
    		
    	}
    
    	reflex receive_placeInfo when: !empty(informs) {
		message informFromInitiator <- informs[0];
		write '(Time ' + time + '): ' + name + ' receives a INFORM message from ' + agent(informFromInitiator.sender).name + ' with content ' + informFromInitiator.contents;
		
		agent auctioneer <- informFromInitiator.contents[2];
		string instruction <- informFromInitiator.contents[1];
		int columnToTry <- informFromInitiator.contents[3];
		firstCol<-columnToTry;
        
		list<queen> agentsL <- list(queen);
		int indexOfSelf <- agents index_of self;
				
			write "Try to Placing Queen: "+indexOfSelf+" in column"+columnToTry;
			if(placeQueen(columnToTry) and indexOfSelf<n_queens_init)
			{
			write "Succeeded Placing Queen: "+indexOfSelf;
			if((firstCol+1)<n_queens_init)
			{
			do start_conversation with: [ to :: list(agentsL[indexOfSelf+1]), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("You should place from "+self.name),"Place",self,(firstCol+1)] ];
			}
			}
			else{
			write "Failed placing Queen: "+indexOfSelf;
			placedOnce<-false;
			lastRow<-0;
			do start_conversation with: [ to :: list(agentsL[indexOfSelf-1]), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [("You should place from "+self.name),"Place",self,(firstCol-1)] ];
			
			}
		
		
		}
    
    aspect base {
    draw circle(size) color: color ;
    }
    
    	int calculateIndex(int rowIn,int colIn)
    {
    	
			int indexCounterL<-0;
			int returnIndex<-0;
				
				loop rowCalc from: 0 to: (N_ofqueens_andBlocks-1) { 
					
					loop colCalc from: 0 to: (N_ofqueens_andBlocks-1) {

						if(rowIn=rowCalc and colIn=colCalc)
						{
							returnIndex<-indexCounterL;
						}
							
						indexCounterL<-indexCounterL+1;
						//write "indexcounterL: "+indexCounterL;						
					} 
				} 
    	return (returnIndex);
    }
    
    
        bool placeQueen(int col2)
    {

        //WHEN WE ARE FINISHED SHOULD NO BE NEEDED
        if (col2 >= N_ofqueens_andBlocks) {
            return true;
        }
        	
        	//Replace then reset old board
        	if(placedOnce)
        	{
        		globalBoard[lastRow][col2] <- 0;  
        	}
        	
        	//We are already on last spot.
        	if(placedOnce and lastRow=(N_ofqueens_andBlocks-1))
        	{
        		return false;
        	}
			
			loop irow from: (!placedOnce ? lastRow : lastRow+1) to: (N_ofqueens_andBlocks-1) {
				
				
				if(irow<N_ofqueens_andBlocks)
				{
				write "Try to place queen:"+self.name+"in: row:"+irow+"icol:"+col2;
				
	            if (checkLeft( irow, col2)) {
	            
	            	
	           	 globalBoard[irow][col2] <- 1;  
	           	 int indexToPlace <- calculateIndex(irow,col2);
	           	 write "Goes safe index"+indexToPlace;
	           	 location<-listcells[indexToPlace];
	           	 lastRow<-irow;
	           	 placedOnce<-true;
	           	 return true;                                   
	            }
	            
	            }
				
			} 


        //If failed to place Queen, send to predecessor
        return false;                                              
    }
    
    
    //checks only left side because used when queens already are there. 
        bool checkLeft(int r, int c)
    {
        int i1;
        int j1;
        
        write "";
                
		// left side
		loop i1 from: 0 to: (c-1) {
			
			if(i1>=0)
			{
            if (globalBoard[r][i1] = 1) {
                return false;
            }
            
            }
		}
		
		// Upright left
		int tempC<-c;
		int tempR<-(r-1);
		if(tempR>=0)
		{
		loop i1 from: tempR to: 0 step: (-1) { 
			tempC<-tempC-1;
			
			if(tempC>=0 and i1>=0)
			{
			
	     	if (globalBoard[i1][tempC] = 1) {
                return false;
            }
            
            }
            else{
            	break;
            }
		}
		}
			
			//Downwards left
 		 	tempC<-c;
			loop i1 from: (r+1) to: (N_ofqueens_andBlocks-1) step: (1) { 
			tempC<-tempC-1;
			
			if(tempC>=0)
			{
			
	     	if (globalBoard[i1][tempC] = 1) {
                return false;
            }
            
            }
            else{
            	break;
            }
		}
 		   
        return true;
    }
      
        
        reflex cellColors 	{
        	
        	int cellCounter<-1;
        	int cellTimes <- 1;
        	rgb startColor <- rgb(int(255 ), 255, int(255));
        	rgb secondColor <- rgb(int(200 ), 200, int(200));
        	
        	
        	//list<board_cell> listcells <- list(board_cell);
        	
        	int index<-0;
        	loop a_temp_var over: listcells { 
			if(index=0)
			{
				listcells[index].color <- rgb(int(255 ), 255, int(255));
			}
			
			else{
			

				
			int checkMod <- index mod 2;
			
			if(checkMod=0)
			{
				listcells[index].color <- startColor;
				
			}
			else{
				listcells[index].color <- secondColor;
			}
				
			}
			
			index<-index+1;
			
			cellCounter<-cellCounter+1;
			//write "cellCounter:"+cellCounter+"index: "+index;
			if(cellCounter>(N_ofqueens_andBlocks))
			{
				int checkTimes <- cellTimes mod 2;
				if(checkTimes=0)
			{
				startColor <- rgb(int(255 ), 255, int(255));
	        	secondColor <- rgb(int(200 ), 200, int(200));
				
			}
			else{
				secondColor <- rgb(int(255 ), 255, int(255));
	        	startColor <- rgb(int(200 ), 200, int(200));
				
			}
			cellCounter<-1;
			checkTimes<-0;
			cellTimes<-cellTimes+1;
			}	

			
			}

        	
        }
    
    
}

grid board_cell width: (N_ofqueens_andBlocks) height: (N_ofqueens_andBlocks) {
    rgb color <- rgb(int(255 ), 255, int(255)) ;
}

experiment queen_baseasshw3 type: gui {
    output {
    display main_display {
        grid board_cell lines: #black ;
        species queen aspect: base ;
    }
    }
}

