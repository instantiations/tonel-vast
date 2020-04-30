Class {
	#name : 'TonelBaseApp',
	#superclass : 'Application',
	#pools : [
		'TonelTextConstants'
	],
	#category : 'TonelBaseApp'
}

{ #category : 'Pool Dictionaries' }
TonelBaseApp class >> _PRAGMA_TonelTextConstants [

	"%%PRAGMA DECLARE
	(name: TonelTextConstants isPool: true isConstant: true)
	(pool: TonelTextConstants declarations: (
		(name: TonelMsg01 isConstant: true valueExpression: '''Load Applications from Tonel packages...''')
		(name: TonelMsg02 isConstant: true valueExpression: '''Export Applications as Tonel packages...''')
		(name: TonelMsg03 isConstant: true valueExpression: '''%1 extends %2, which is not defined in the image''')
		(name: TonelMsg04 isConstant: true valueExpression: '''%1 defines %2 as a subclass of %3, which is not defined in the image''')
		(name: TonelMsg05 isConstant: true valueExpression: '''The SubApplication %1 exists in the image, but is a subapplication of %2, not %3''')
		(name: TonelMsg06 isConstant: true valueExpression: '''Application %1 exists but is not loaded. Please choose a base version.''')
		(name: TonelMsg07 isConstant: true valueExpression: '''%1 %2''')
		(name: TonelMsg08 isConstant: true valueExpression: '''You need to choose a base edition from which to create %1''')
		(name: TonelMsg09 isConstant: true valueExpression: '''Base edition for %1 is managed by %2. You are currently %3 and cannot create new editions of the application.''')
		(name: TonelMsg10 isConstant: true valueExpression: '''Missing superclass for %1''')
		(name: TonelMsg11 isConstant: true valueExpression: '''Enter the version name to be used for imported classes and applications''') 
		(name: TonelMsg12 isConstant: true valueExpression: '''Select Tonel repository path''')
		(name: TonelMsg13 isConstant: true valueExpression: '''Please select the prequisites for %1 (chains will be resolved after selection)''')
		(name: TonelMsg14 isConstant: true valueExpression: '''The selected Tonel repository does not contain a valid sources directory.''')
		(name: TonelMsg15 isConstant: true valueExpression: '''Select Tonel Packages to be imported as VAST Applications''')
		(name: TonelMsg16 isConstant: true valueExpression: '''The following source failed to compile (all double quotes have been doubled):''')
		(name: TonelMsg17 isConstant: true valueExpression: '''^ self halt: ''''The source for this method failed to compile'''' ''')
		(name: TonelMsg18 isConstant: true valueExpression: '''Could not load base edition of %1. Load aborted.''')
		(name: TonelMsg19 isConstant: true valueExpression: '''The following subapplications were not imported: ''')
		(name: TonelMsg20 isConstant: true valueExpression: '''Loading... <1s>''')
		(name: TonelMsg21 isConstant: true valueExpression: '''The following Tonel Packages will be imported as VAST Applications''')
		(name: TonelMsg22 isConstant: true valueExpression: '''Available Tonel Packages''')		
		(name: TonelMsg23 isConstant: true valueExpression: '''Selected Tonel Packages''')				
		(name: TonelMsg24 isConstant: true valueExpression: '''Name: %1%0Author: %2%0Time: %3, %4%0%0%5''')
		(name: TonelMsg25 isConstant: true valueExpression: '''The selected Tonel repository is not valid or does not contain any package.''')	
		(name: TonelMsg27 isConstant: true valueExpression: '''Select applications to export in Tonel format''')	
		(name: TonelMsg28 isConstant: true valueExpression: '''Select which applications you want to export in Tonel format to a specific''')			
		(name: TonelMsg29 isConstant: true valueExpression: '''Available applications''')			
		(name: TonelMsg30 isConstant: true valueExpression: '''Applications to be exported''')			
		(name: TonelMsg31 isConstant: true valueExpression: '''Select a target path''')			
		
		
	))"

]
