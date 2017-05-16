//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "DebugUITableViewController.h"
#import "Environment.h"
#import "Signal-Swift.h"
#import "ThreadUtil.h"
#import <SignalServiceKit/TSStorageManager+SessionStore.h>
#import <SignalServiceKit/TSThread.h>

NS_ASSUME_NONNULL_BEGIN

@implementation DebugUITableViewController

#pragma mark - Logging

+ (NSString *)tag
{
    return [NSString stringWithFormat:@"[%@]", self.class];
}

- (NSString *)tag
{
    return self.class.tag;
}

#pragma mark - Factory Methods

+ (void)presentDebugUIForThread:(TSThread *)thread
             fromViewController:(UIViewController *)fromViewController {
    OWSAssert(thread);
    OWSAssert(fromViewController);

    OWSTableContents *contents = [OWSTableContents new];
    contents.title = @"Debug: Conversation";

    [contents
        addSection:[OWSTableSection
                       sectionWithTitle:@"Messages View"
                                  items:@[
                                      [OWSTableItem itemWithTitle:@"Send 10 messages (1/sec.)"
                                                      actionBlock:^{
                                                          [DebugUITableViewController sendTextMessage:10 thread:thread];
                                                      }],
                                      [OWSTableItem itemWithTitle:@"Send 100 messages (1/sec.)"
                                                      actionBlock:^{
                                                          [DebugUITableViewController sendTextMessage:100
                                                                                               thread:thread];
                                                      }],
                                      [OWSTableItem itemWithTitle:@"Send 1,000 messages (1/sec.)"
                                                      actionBlock:^{
                                                          [DebugUITableViewController sendTextMessage:1000
                                                                                               thread:thread];
                                                      }],
                                      [OWSTableItem itemWithTitle:@"Send text/x-signal-plain"
                                                      actionBlock:^{
                                                          [DebugUITableViewController sendOversizeTextMessage:thread];
                                                      }],
                                      [OWSTableItem
                                          itemWithTitle:@"Send unknown mimetype"
                                            actionBlock:^{
                                                [DebugUITableViewController
                                                    sendRandomAttachment:thread
                                                                     uti:SignalAttachment.kUnknownTestAttachmentUTI];
                                            }],
                                      [OWSTableItem itemWithTitle:@"Send pdf"
                                                      actionBlock:^{
                                                          [DebugUITableViewController
                                                              sendRandomAttachment:thread
                                                                               uti:(NSString *)kUTTypePDF];
                                                      }],
                                  ]]];

    [contents
        addSection:[OWSTableSection
                       sectionWithTitle:@"Session State"
                                  items:@[
                                      [OWSTableItem itemWithTitle:@"Print all sessions"
                                                      actionBlock:^{
                                                          dispatch_async([OWSDispatch sessionStoreQueue], ^{
                                                              [[TSStorageManager sharedManager] printAllSessions];
                                                          });
                                                      }],
                                      [OWSTableItem
                                          itemWithTitle:@"Delete session (Contact Thread Only)"
                                            actionBlock:^{
                                                if (![thread isKindOfClass:[TSContactThread class]]) {
                                                    DDLogError(@"Refusing to delete session for group thread.");
                                                    OWSAssert(NO);
                                                    return;
                                                }
                                                TSContactThread *contactThread = (TSContactThread *)thread;
                                                dispatch_async([OWSDispatch sessionStoreQueue], ^{
                                                    [[TSStorageManager sharedManager]
                                                        deleteAllSessionsForContact:contactThread.contactIdentifier];
                                                });
                                            }],
                                      [OWSTableItem
                                          itemWithTitle:@"Send session reset (Contact Thread Only)"
                                            actionBlock:^{
                                                if (![thread isKindOfClass:[TSContactThread class]]) {
                                                    DDLogError(@"Refusing to reset session for group thread.");
                                                    OWSAssert(NO);
                                                    return;
                                                }
                                                TSContactThread *contactThread = (TSContactThread *)thread;
                                                [OWSSessionResetJob
                                                    runWithContactThread:contactThread
                                                           messageSender:[Environment getCurrent].messageSender
                                                          storageManager:[TSStorageManager sharedManager]];
                                            }]

                                  ]]];

    [contents addSection:[OWSTableSection
                             sectionWithTitle:@"Misc."
                                        items:@[
                                            [OWSTableItem itemWithTitle:@"Create 1 Random Contact"
                                                            actionBlock:^{
                                                                [DebugUITableViewController createRandomContacts:1];
                                                            }],
                                            [OWSTableItem itemWithTitle:@"Create 100 Random Contacts"
                                                            actionBlock:^{
                                                                [DebugUITableViewController createRandomContacts:100];
                                                            }],
                                            [OWSTableItem itemWithTitle:@"Delete Random Contacts"
                                                            actionBlock:^{
                                                                [DebugUITableViewController deleteRandomContacts];
                                                            }],
                                        ]]];

    DebugUITableViewController *viewController = [DebugUITableViewController new];
    viewController.contents = contents;
    [viewController presentFromViewController:fromViewController];
}

+ (NSString *)randomFirstName
{
    NSArray<NSString *> *values = @[
        @"Alice",
        @"Bob",
        @"Carol",
        @"Carlos",
        @"Charlie",
        @"Chuck",
        @"Craig",
        @"Dan",
        @"Dave",
        @"David",
        @"Erin",
        @"Eve.",
        @"Eve",
        @"Faythe",
        @"Frank",
        @"Grace",
        @"Heidi",
        @"Mallory",
        @"Mallet",
        @"Oscar",
        @"Peggy",
        @"Pat",
        @"Sybil",
        @"Trent",
        @"Ted",
        @"Trudy",
        @"Victor",
        @"Vanna",
        @"Walter",
        @"Wendy",
        @"Arthur",
        @"Merlin",
        @"Paul",
        @"Carole",
        @"Paul",
        @"Bertha",
    ];
    return values[arc4random_uniform(values.count)];
}


+ (NSString *)randomLastName
{
    NSArray<NSString *> *values = @[
        @"Smith",
        @"Johnson",
        @"Williams",
        @"Jones",
        @"Brown",
        @"Davis",
        @"Miller",
        @"Wilson",
        @"Moore",
        @"Taylor",
        @"Anderson",
        @"Thomas",
        @"Jackson",
        @"White",
        @"Harris",
        @"Martin",
        @"Thompson",
        @"Garcia",
        @"Martinez",
        @"Robinson",
        @"Clark",
        @"Rodriguez",
        @"Lewis",
        @"Lee",
        @"Walker",
        @"Hall",
        @"Allen",
        @"Young",
        @"Hernandez",
        @"King",
        @"Wright",
        @"Lopez",
        @"Hill",
        @"Scott",
        @"Green",
        @"Adams",
        @"Baker",
        @"Gonzalez",
        @"Nelson",
        @"Carter",
        @"Mitchell",
        @"Perez",
        @"Roberts",
        @"Turner",
        @"Phillips",
        @"Campbell",
        @"Parker",
        @"Evans",
        @"Edwards",
        @"Collins",
        @"Stewart",
        @"Sanchez",
        @"Morris",
        @"Rogers",
        @"Reed",
        @"Cook",
        @"Morgan",
        @"Bell",
        @"Murphy",
        @"Bailey",
        @"Rivera",
        @"Cooper",
        @"Richardson",
        @"Cox",
        @"Howard",
        @"Ward",
        @"Torres",
        @"Peterson",
        @"Gray",
        @"Ramirez",
        @"James",
        @"Watson",
        @"Brooks",
        @"Kelly",
        @"Sanders",
        @"Price",
        @"Bennett",
        @"Wood",
        @"Barnes",
        @"Ross",
        @"Henderson",
        @"Coleman",
        @"Jenkins",
        @"Perry",
        @"Powell",
        @"Long",
        @"Patterson",
        @"Hughes",
        @"Flores",
        @"Washington",
        @"Butler",
        @"Simmons",
        @"Foster",
        @"Gonzales",
        @"Bryant",
        @"Alexander",
        @"Russell",
        @"Griffin",
        @"Diaz",
        @"Hayes",
        @"Myers",
        @"Ford",
        @"Hamilton",
        @"Graham",
        @"Sullivan",
        @"Wallace",
        @"Woods",
        @"Cole",
        @"West",
        @"Jordan",
        @"Owens",
        @"Reynolds",
        @"Fisher",
        @"Ellis",
        @"Harrison",
        @"Gibson",
        @"Mcdonald",
        @"Cruz",
        @"Marshall",
        @"Ortiz",
        @"Gomez",
        @"Murray",
        @"Freeman",
        @"Wells",
        @"Webb",
        @"Simpson",
        @"Stevens",
        @"Tucker",
        @"Porter",
        @"Hunter",
        @"Hicks",
        @"Crawford",
        @"Henry",
        @"Boyd",
        @"Mason",
        @"Morales",
        @"Kennedy",
        @"Warren",
        @"Dixon",
        @"Ramos",
        @"Reyes",
        @"Burns",
        @"Gordon",
        @"Shaw",
        @"Holmes",
        @"Rice",
        @"Robertson",
        @"Hunt",
        @"Black",
        @"Daniels",
        @"Palmer",
        @"Mills",
        @"Nichols",
        @"Grant",
        @"Knight",
        @"Ferguson",
        @"Rose",
        @"Stone",
        @"Hawkins",
        @"Dunn",
        @"Perkins",
        @"Hudson",
        @"Spencer",
        @"Gardner",
        @"Stephens",
        @"Payne",
        @"Pierce",
        @"Berry",
        @"Matthews",
        @"Arnold",
        @"Wagner",
        @"Willis",
        @"Ray",
        @"Watkins",
        @"Olson",
        @"Carroll",
        @"Duncan",
        @"Snyder",
        @"Hart",
        @"Cunningham",
        @"Bradley",
        @"Lane",
        @"Andrews",
        @"Ruiz",
        @"Harper",
        @"Fox",
        @"Riley",
        @"Armstrong",
        @"Carpenter",
        @"Weaver",
        @"Greene",
        @"Lawrence",
        @"Elliott",
        @"Chavez",
        @"Sims",
        @"Austin",
        @"Peters",
        @"Kelley",
        @"Franklin",
        @"Lawson",
        @"Fields",
        @"Gutierrez",
        @"Ryan",
        @"Schmidt",
        @"Carr",
        @"Vasquez",
        @"Castillo",
        @"Wheeler",
        @"Chapman",
        @"Oliver",
        @"Montgomery",
        @"Richards",
        @"Williamson",
        @"Johnston",
        @"Banks",
        @"Meyer",
        @"Bishop",
        @"Mccoy",
        @"Howell",
        @"Alvarez",
        @"Morrison",
        @"Hansen",
        @"Fernandez",
        @"Garza",
        @"Harvey",
        @"Little",
        @"Burton",
        @"Stanley",
        @"Nguyen",
        @"George",
        @"Jacobs",
        @"Reid",
        @"Kim",
        @"Fuller",
        @"Lynch",
        @"Dean",
        @"Gilbert",
        @"Garrett",
        @"Romero",
        @"Welch",
        @"Larson",
        @"Frazier",
        @"Burke",
        @"Hanson",
        @"Day",
        @"Mendoza",
        @"Moreno",
        @"Bowman",
        @"Medina",
        @"Fowler",
        @"Brewer",
        @"Hoffman",
        @"Carlson",
        @"Silva",
        @"Pearson",
        @"Holland",
        @"Douglas",
        @"Fleming",
        @"Jensen",
        @"Vargas",
        @"Byrd",
        @"Davidson",
        @"Hopkins",
        @"May",
        @"Terry",
        @"Herrera",
        @"Wade",
        @"Soto",
        @"Walters",
        @"Curtis",
        @"Neal",
        @"Caldwell",
        @"Lowe",
        @"Jennings",
        @"Barnett",
        @"Graves",
        @"Jimenez",
        @"Horton",
        @"Shelton",
        @"Barrett",
        @"O'brien",
        @"Castro",
        @"Sutton",
        @"Gregory",
        @"Mckinney",
        @"Lucas",
        @"Miles",
        @"Craig",
        @"Rodriquez",
        @"Chambers",
        @"Holt",
        @"Lambert",
        @"Fletcher",
        @"Watts",
        @"Bates",
        @"Hale",
        @"Rhodes",
        @"Pena",
        @"Beck",
        @"Newman",
        @"Haynes",
        @"Mcdaniel",
        @"Mendez",
        @"Bush",
        @"Vaughn",
        @"Parks",
        @"Dawson",
        @"Santiago",
        @"Norris",
        @"Hardy",
        @"Love",
        @"Steele",
        @"Curry",
        @"Powers",
        @"Schultz",
        @"Barker",
        @"Guzman",
        @"Page",
        @"Munoz",
        @"Ball",
        @"Keller",
        @"Chandler",
        @"Weber",
        @"Leonard",
        @"Walsh",
        @"Lyons",
        @"Ramsey",
        @"Wolfe",
        @"Schneider",
        @"Mullins",
        @"Benson",
        @"Sharp",
        @"Bowen",
        @"Daniel",
        @"Barber",
        @"Cummings",
        @"Hines",
        @"Baldwin",
        @"Griffith",
        @"Valdez",
        @"Hubbard",
        @"Salazar",
        @"Reeves",
        @"Warner",
        @"Stevenson",
        @"Burgess",
        @"Santos",
        @"Tate",
        @"Cross",
        @"Garner",
        @"Mann",
        @"Mack",
        @"Moss",
        @"Thornton",
        @"Dennis",
        @"Mcgee",
        @"Farmer",
        @"Delgado",
        @"Aguilar",
        @"Vega",
        @"Glover",
        @"Manning",
        @"Cohen",
        @"Harmon",
        @"Rodgers",
        @"Robbins",
        @"Newton",
        @"Todd",
        @"Blair",
        @"Higgins",
        @"Ingram",
        @"Reese",
        @"Cannon",
        @"Strickland",
        @"Townsend",
        @"Potter",
        @"Goodwin",
        @"Walton",
        @"Rowe",
        @"Hampton",
        @"Ortega",
        @"Patton",
        @"Swanson",
        @"Joseph",
        @"Francis",
        @"Goodman",
        @"Maldonado",
        @"Yates",
        @"Becker",
        @"Erickson",
        @"Hodges",
        @"Rios",
        @"Conner",
        @"Adkins",
        @"Webster",
        @"Norman",
        @"Malone",
        @"Hammond",
        @"Flowers",
        @"Cobb",
        @"Moody",
        @"Quinn",
        @"Blake",
        @"Maxwell",
        @"Pope",
        @"Floyd",
        @"Osborne",
        @"Paul",
        @"Mccarthy",
        @"Guerrero",
        @"Lindsey",
        @"Estrada",
        @"Sandoval",
        @"Gibbs",
        @"Tyler",
        @"Gross",
        @"Fitzgerald",
        @"Stokes",
        @"Doyle",
        @"Sherman",
        @"Saunders",
        @"Wise",
        @"Colon",
        @"Gill",
        @"Alvarado",
        @"Greer",
        @"Padilla",
        @"Simon",
        @"Waters",
        @"Nunez",
        @"Ballard",
        @"Schwartz",
        @"Mcbride",
        @"Houston",
        @"Christensen",
        @"Klein",
        @"Pratt",
        @"Briggs",
        @"Parsons",
        @"Mclaughlin",
        @"Zimmerman",
        @"French",
        @"Buchanan",
        @"Moran",
        @"Copeland",
        @"Roy",
        @"Pittman",
        @"Brady",
        @"Mccormick",
        @"Holloway",
        @"Brock",
        @"Poole",
        @"Frank",
        @"Logan",
        @"Owen",
        @"Bass",
        @"Marsh",
        @"Drake",
        @"Wong",
        @"Jefferson",
        @"Park",
        @"Morton",
        @"Abbott",
        @"Sparks",
        @"Patrick",
        @"Norton",
        @"Huff",
        @"Clayton",
        @"Massey",
        @"Lloyd",
        @"Figueroa",
        @"Carson",
        @"Bowers",
        @"Roberson",
        @"Barton",
        @"Tran",
        @"Lamb",
        @"Harrington",
        @"Casey",
        @"Boone",
        @"Cortez",
        @"Clarke",
        @"Mathis",
        @"Singleton",
        @"Wilkins",
        @"Cain",
        @"Bryan",
        @"Underwood",
        @"Hogan",
        @"Mckenzie",
        @"Collier",
        @"Luna",
        @"Phelps",
        @"Mcguire",
        @"Allison",
        @"Bridges",
        @"Wilkerson",
        @"Nash",
        @"Summers",
        @"Atkins",
        @"Wilcox",
        @"Pitts",
        @"Conley",
        @"Marquez",
        @"Burnett",
        @"Richard",
        @"Cochran",
        @"Chase",
        @"Davenport",
        @"Hood",
        @"Gates",
        @"Clay",
        @"Ayala",
        @"Sawyer",
        @"Roman",
        @"Vazquez",
        @"Dickerson",
        @"Hodge",
        @"Acosta",
        @"Flynn",
        @"Espinoza",
        @"Nicholson",
        @"Monroe",
        @"Wolf",
        @"Morrow",
        @"Kirk",
        @"Randall",
        @"Anthony",
        @"Whitaker",
        @"O'connor",
        @"Skinner",
        @"Ware",
        @"Molina",
        @"Kirby",
        @"Huffman",
        @"Bradford",
        @"Charles",
        @"Gilmore",
        @"Dominguez",
        @"O'neal",
        @"Bruce",
        @"Lang",
        @"Combs",
        @"Kramer",
        @"Heath",
        @"Hancock",
        @"Gallagher",
        @"Gaines",
        @"Shaffer",
        @"Short",
        @"Wiggins",
        @"Mathews",
        @"Mcclain",
        @"Fischer",
        @"Wall",
        @"Small",
        @"Melton",
        @"Hensley",
        @"Bond",
        @"Dyer",
        @"Cameron",
        @"Grimes",
        @"Contreras",
        @"Christian",
        @"Wyatt",
        @"Baxter",
        @"Snow",
        @"Mosley",
        @"Shepherd",
        @"Larsen",
        @"Hoover",
        @"Beasley",
        @"Glenn",
        @"Petersen",
        @"Whitehead",
        @"Meyers",
        @"Keith",
        @"Garrison",
        @"Vincent",
        @"Shields",
        @"Horn",
        @"Savage",
        @"Olsen",
        @"Schroeder",
        @"Hartman",
        @"Woodard",
        @"Mueller",
        @"Kemp",
        @"Deleon",
        @"Booth",
        @"Patel",
        @"Calhoun",
        @"Wiley",
        @"Eaton",
        @"Cline",
        @"Navarro",
        @"Harrell",
        @"Lester",
        @"Humphrey",
        @"Parrish",
        @"Duran",
        @"Hutchinson",
        @"Hess",
        @"Dorsey",
        @"Bullock",
        @"Robles",
        @"Beard",
        @"Dalton",
        @"Avila",
        @"Vance",
        @"Rich",
        @"Blackwell",
        @"York",
        @"Johns",
        @"Blankenship",
        @"Trevino",
        @"Salinas",
        @"Campos",
        @"Pruitt",
        @"Moses",
        @"Callahan",
        @"Golden",
        @"Montoya",
        @"Hardin",
        @"Guerra",
        @"Mcdowell",
        @"Carey",
        @"Stafford",
        @"Gallegos",
        @"Henson",
        @"Wilkinson",
        @"Booker",
        @"Merritt",
        @"Miranda",
        @"Atkinson",
        @"Orr",
        @"Decker",
        @"Hobbs",
        @"Preston",
        @"Tanner",
        @"Knox",
        @"Pacheco",
        @"Stephenson",
        @"Glass",
        @"Rojas",
        @"Serrano",
        @"Marks",
        @"Hickman",
        @"English",
        @"Sweeney",
        @"Strong",
        @"Prince",
        @"Mcclure",
        @"Conway",
        @"Walter",
        @"Roth",
        @"Maynard",
        @"Farrell",
        @"Lowery",
        @"Hurst",
        @"Nixon",
        @"Weiss",
        @"Trujillo",
        @"Ellison",
        @"Sloan",
        @"Juarez",
        @"Winters",
        @"Mclean",
        @"Randolph",
        @"Leon",
        @"Boyer",
        @"Villarreal",
        @"Mccall",
        @"Gentry",
        @"Carrillo",
        @"Kent",
        @"Ayers",
        @"Lara",
        @"Shannon",
        @"Sexton",
        @"Pace",
        @"Hull",
        @"Leblanc",
        @"Browning",
        @"Velasquez",
        @"Leach",
        @"Chang",
        @"House",
        @"Sellers",
        @"Herring",
        @"Noble",
        @"Foley",
        @"Bartlett",
        @"Mercado",
        @"Landry",
        @"Durham",
        @"Walls",
        @"Barr",
        @"Mckee",
        @"Bauer",
        @"Rivers",
        @"Everett",
        @"Bradshaw",
        @"Pugh",
        @"Velez",
        @"Rush",
        @"Estes",
        @"Dodson",
        @"Morse",
        @"Sheppard",
        @"Weeks",
        @"Camacho",
        @"Bean",
        @"Barron",
        @"Livingston",
        @"Middleton",
        @"Spears",
        @"Branch",
        @"Blevins",
        @"Chen",
        @"Kerr",
        @"Mcconnell",
        @"Hatfield",
        @"Harding",
        @"Ashley",
        @"Solis",
        @"Herman",
        @"Frost",
        @"Giles",
        @"Blackburn",
        @"William",
        @"Pennington",
        @"Woodward",
        @"Finley",
        @"Mcintosh",
        @"Koch",
        @"Best",
        @"Solomon",
        @"Mccullough",
        @"Dudley",
        @"Nolan",
        @"Blanchard",
        @"Rivas",
        @"Brennan",
        @"Mejia",
        @"Kane",
        @"Benton",
        @"Joyce",
        @"Buckley",
        @"Haley",
        @"Valentine",
        @"Maddox",
        @"Russo",
        @"Mcknight",
        @"Buck",
        @"Moon",
        @"Mcmillan",
        @"Crosby",
        @"Berg",
        @"Dotson",
        @"Mays",
        @"Roach",
        @"Church",
        @"Chan",
        @"Richmond",
        @"Meadows",
        @"Faulkner",
        @"O'neill",
        @"Knapp",
        @"Kline",
        @"Barry",
        @"Ochoa",
        @"Jacobson",
        @"Gay",
        @"Avery",
        @"Hendricks",
        @"Horne",
        @"Shepard",
        @"Hebert",
        @"Cherry",
        @"Cardenas",
        @"Mcintyre",
        @"Whitney",
        @"Waller",
        @"Holman",
        @"Donaldson",
        @"Cantu",
        @"Terrell",
        @"Morin",
        @"Gillespie",
        @"Fuentes",
        @"Tillman",
        @"Sanford",
        @"Bentley",
        @"Peck",
        @"Key",
        @"Salas",
        @"Rollins",
        @"Gamble",
        @"Dickson",
        @"Battle",
        @"Santana",
        @"Cabrera",
        @"Cervantes",
        @"Howe",
        @"Hinton",
        @"Hurley",
        @"Spence",
        @"Zamora",
        @"Yang",
        @"Mcneil",
        @"Suarez",
        @"Case",
        @"Petty",
        @"Gould",
        @"Mcfarland",
        @"Sampson",
        @"Carver",
        @"Bray",
        @"Rosario",
        @"Macdonald",
        @"Stout",
        @"Hester",
        @"Melendez",
        @"Dillon",
        @"Farley",
        @"Hopper",
        @"Galloway",
        @"Potts",
        @"Bernard",
        @"Joyner",
        @"Stein",
        @"Aguirre",
        @"Osborn",
        @"Mercer",
        @"Bender",
        @"Franco",
        @"Rowland",
        @"Sykes",
        @"Benjamin",
        @"Travis",
        @"Pickett",
        @"Crane",
        @"Sears",
        @"Mayo",
        @"Dunlap",
        @"Hayden",
        @"Wilder",
        @"Mckay",
        @"Coffey",
        @"Mccarty",
        @"Ewing",
        @"Cooley",
        @"Vaughan",
        @"Bonner",
        @"Cotton",
        @"Holder",
        @"Stark",
        @"Ferrell",
        @"Cantrell",
        @"Fulton",
        @"Lynn",
        @"Lott",
        @"Calderon",
        @"Rosa",
        @"Pollard",
        @"Hooper",
        @"Burch",
        @"Mullen",
        @"Fry",
        @"Riddle",
        @"Levy",
        @"David",
        @"Duke",
        @"O'donnell",
        @"Guy",
        @"Michael",
        @"Britt",
        @"Frederick",
        @"Daugherty",
        @"Berger",
        @"Dillard",
        @"Alston",
        @"Jarvis",
        @"Frye",
        @"Riggs",
        @"Chaney",
        @"Odom",
        @"Duffy",
        @"Fitzpatrick",
        @"Valenzuela",
        @"Merrill",
        @"Mayer",
        @"Alford",
        @"Mcpherson",
        @"Acevedo",
        @"Donovan",
        @"Barrera",
        @"Albert",
        @"Cote",
        @"Reilly",
        @"Compton",
        @"Raymond",
        @"Mooney",
        @"Mcgowan",
        @"Craft",
        @"Cleveland",
        @"Clemons",
        @"Wynn",
        @"Nielsen",
        @"Baird",
        @"Stanton",
        @"Snider",
        @"Rosales",
        @"Bright",
        @"Witt",
        @"Stuart",
        @"Hays",
        @"Holden",
        @"Rutledge",
        @"Kinney",
        @"Clements",
        @"Castaneda",
        @"Slater",
        @"Hahn",
        @"Emerson",
        @"Conrad",
        @"Burks",
        @"Delaney",
        @"Pate",
        @"Lancaster",
        @"Sweet",
        @"Justice",
        @"Tyson",
        @"Sharpe",
        @"Whitfield",
        @"Talley",
        @"Macias",
        @"Irwin",
        @"Burris",
        @"Ratliff",
        @"Mccray",
        @"Madden",
        @"Kaufman",
        @"Beach",
        @"Goff",
        @"Cash",
        @"Bolton",
        @"Mcfadden",
        @"Levine",
        @"Good",
        @"Byers",
        @"Kirkland",
        @"Kidd",
        @"Workman",
        @"Carney",
        @"Dale",
        @"Mcleod",
        @"Holcomb",
        @"England",
        @"Finch",
        @"Head",
        @"Burt",
        @"Hendrix",
        @"Sosa",
        @"Haney",
        @"Franks",
        @"Sargent",
        @"Nieves",
        @"Downs",
        @"Rasmussen",
        @"Bird",
        @"Hewitt",
        @"Lindsay",
        @"Le",
        @"Foreman",
        @"Valencia",
        @"O'neil",
        @"Delacruz",
        @"Vinson",
        @"Dejesus",
        @"Hyde",
        @"Forbes",
        @"Gilliam",
        @"Guthrie",
        @"Wooten",
        @"Huber",
        @"Barlow",
        @"Boyle",
        @"Mcmahon",
        @"Buckner",
        @"Rocha",
        @"Puckett",
        @"Langley",
        @"Knowles",
        @"Cooke",
        @"Velazquez",
        @"Whitley",
        @"Noel",
        @"Vang",
    ];
    return values[arc4random_uniform(values.count)];
}


+ (NSString *)randomPhoneNumber
{
    if (arc4random_uniform(2) == 0) {
        // Generate a US phone number.
        NSMutableString *result = [@"+1" mutableCopy];
        for (int i = 0; i < 10; i++) {
            // Add digits.
            [result appendString:[@(arc4random_uniform(10)) description]];
        }
        return result;
    } else {
        // Generate a UK phone number.
        NSMutableString *result = [@"+441" mutableCopy];
        for (int i = 0; i < 9; i++) {
            // Add digits.
            [result appendString:[@(arc4random_uniform(10)) description]];
        }
        return result;
    }
}

+ (void)createRandomContacts:(int)count
{
    OWSAssert(count > 0);

    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted) {
        [OWSAlerts showAlertWithTitle:@"Error" message:@"No contacts access."];
        return;
    }

    CNContactStore *store = [[CNContactStore alloc] init];
    [store
        requestAccessForEntityType:CNEntityTypeContacts
                 completionHandler:^(BOOL granted, NSError *_Nullable error) {
                     if (!granted || error) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [OWSAlerts showAlertWithTitle:@"Error" message:@"No contacts access."];
                         });
                         return;
                     }

                     CNSaveRequest *request = [[CNSaveRequest alloc] init];
                     for (int i = 0; i < count; i++) {
                         CNMutableContact *contact = [[CNMutableContact alloc] init];
                         contact.familyName = [@"Rando-" stringByAppendingString:[self randomLastName]];
                         contact.givenName = [self randomFirstName];

                         CNLabeledValue *homePhone = [CNLabeledValue
                             labeledValueWithLabel:CNLabelHome
                                             value:[CNPhoneNumber phoneNumberWithStringValue:[self randomPhoneNumber]]];
                         contact.phoneNumbers = @[ homePhone ];

                         [request addContact:contact toContainerWithIdentifier:nil];
                     }
                     NSError *saveError = nil;
                     if (![store executeSaveRequest:request error:&saveError]) {
                         NSLog(@"error = %@", saveError);
                         [OWSAlerts showAlertWithTitle:@"Error" message:saveError.localizedDescription];
                     }
                 }];
}

+ (void)deleteRandomContacts
{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted) {
        [OWSAlerts showAlertWithTitle:@"Error" message:@"No contacts access."];
        return;
    }

    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts
                    completionHandler:^(BOOL granted, NSError *_Nullable error) {
                        if (!granted || error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [OWSAlerts showAlertWithTitle:@"Error" message:@"No contacts access."];
                            });
                            return;
                        }

                        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[
                            CNContactIdentifierKey,
                            CNContactGivenNameKey,
                            CNContactFamilyNameKey,
                            [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],
                        ]];
                        CNSaveRequest *request = [[CNSaveRequest alloc] init];
                        NSError *fetchError = nil;
                        BOOL result =
                            [store enumerateContactsWithFetchRequest:fetchRequest
                                                               error:&fetchError
                                                          usingBlock:^(CNContact *contact, BOOL *stop) {
                                                              if ([contact.familyName hasPrefix:@"Rando-"]) {
                                                                  [request deleteContact:[contact mutableCopy]];
                                                              }
                                                          }];

                        NSError *saveError = nil;
                        if (!result || fetchError) {
                            NSLog(@"error = %@", fetchError);
                            [OWSAlerts showAlertWithTitle:@"Error" message:fetchError.localizedDescription];
                        } else if (![store executeSaveRequest:request error:&saveError]) {
                            NSLog(@"error = %@", saveError);
                            [OWSAlerts showAlertWithTitle:@"Error" message:saveError.localizedDescription];
                        }
                    }];
}

+ (void)sendTextMessage:(int)counter
                 thread:(TSThread *)thread {
    OWSMessageSender *messageSender = [Environment getCurrent].messageSender;
    if (counter < 1) {
        return;
    }
    [ThreadUtil
        sendMessageWithText:[[@(counter) description]
                                stringByAppendingString:@" Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                                                        @"Suspendisse rutrum, nulla vitae pretium hendrerit, tellus "
                                                        @"turpis pharetra libero, vitae sodales tortor ante vel sem."]
                   inThread:thread
              messageSender:messageSender];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) 1.f * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
                       [self sendTextMessage:counter - 1 thread:thread];
                   });
}

+ (void)sendOversizeTextMessage:(TSThread *)thread {
    OWSMessageSender *messageSender = [Environment getCurrent].messageSender;
    NSMutableString *message = [NSMutableString new];
    for (int i=0; i < 32; i++) {
        [message appendString:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse rutrum, nulla vitae pretium hendrerit, tellus turpis pharetra libero, vitae sodales tortor ante vel sem. Fusce sed nisl a lorem gravida tincidunt. Suspendisse efficitur non quam ac sodales. Aenean ut velit maximus, posuere sem a, accumsan nunc. Donec ullamcorper turpis lorem. Quisque dignissim purus eu placerat ultricies. Proin at urna eget mi semper congue. Aenean non elementum ex. Praesent pharetra quam at sem vestibulum, vestibulum ornare dolor elementum. Vestibulum massa tortor, scelerisque sit amet pulvinar a, rhoncus vitae nisl. Sed mi nunc, tempus at varius in, malesuada vitae dui. Vivamus efficitur pulvinar erat vitae congue. Proin vehicula turpis non felis congue facilisis. Nullam aliquet dapibus ligula ac mollis. Etiam sit amet posuere lorem, in rhoncus nisi."];
    }

    SignalAttachment *attachment = [SignalAttachment attachmentWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                                dataUTI:SignalAttachment.kOversizeTextAttachmentUTI
                                                               filename:nil];
    [ThreadUtil sendMessageWithAttachment:attachment
                                 inThread:thread
                            messageSender:messageSender];
}

+ (NSData*)createRandomNSDataOfSize:(size_t)size
{
    OWSAssert(size % 4 == 0);
    
    NSMutableData* data = [NSMutableData dataWithCapacity:size];
    for (size_t i = 0; i < size / 4; ++i)
    {
        u_int32_t randomBits = arc4random();
        [data appendBytes:(void *)&randomBits length:4];
    }
    return data;
}

+ (void)sendRandomAttachment:(TSThread *)thread
                         uti:(NSString *)uti {
    OWSMessageSender *messageSender = [Environment getCurrent].messageSender;
    SignalAttachment *attachment =
        [SignalAttachment attachmentWithData:[self createRandomNSDataOfSize:256] dataUTI:uti filename:nil];
    [ThreadUtil sendMessageWithAttachment:attachment
                                 inThread:thread
                            messageSender:messageSender];
}

@end

NS_ASSUME_NONNULL_END
