const map = require( "./pull-list.json" );
const http = require( "https" );
const jsdom = require("jsdom");
const fs = require( "fs" ).promises;

const site = "https://eso-sets.com";
let sets = Object.keys( map );

async function runSets(){
  let setList = [];
  for( let i = 0; i < sets.length; i++ ){
    //let i = 10;
    setList.push( await runSingleSet( sets[i], map[sets[i]] ) );
  }
  
  await fs.writeFile( "./generate-list.json", JSON.stringify( setList, null, 2 ) );
}

async function runSingleSet( setName, setUrl ){
  let result = await getSet( setUrl );
  let setData = parseData( result );

  setData.nameLink = setName;
  setData.uri = setUrl;
  return setData;
}

function getSet( setUrl ){
  return new Promise( ( resolve, reject ) => {
    console.log( `${site}${setUrl}` );
    http.get( `${site}${setUrl}`, ( res ) => {
      const { statusCode } = res;
      const contentType = res.headers['content-type'];

      let error;
      if (statusCode !== 200) {
        error = new Error('Request Failed.\n' +
                          `Status Code: ${statusCode}`);
      }
      if (error) {
        console.error(error.message);
        // Consume response data to free up memory
        res.resume();
        reject( error );
      }
      res.setEncoding('utf8');
      let rawData = '';
      res.on('data', (chunk) => { rawData += chunk; });
      res.on('end', () => {
        try {
          resolve( rawData );
        } catch (e) {
          console.error(e.message);
          reject( e );
        }
      });
    } );
  });
}

function parseData(html){
  const {JSDOM} = jsdom;
  const dom = new JSDOM(html);
  const $ = (require('jquery'))(dom.window);

  //let's start extracting the data

  let mappedData = $(".global-container > .row > .col > .row:nth-child( 2 ) > .col-md-7" ).html();
  mappedData = mappedData.replace( /<li>/gi, "*" ).replace( /<[A-z]+>/gi, "" ).replace( /<\/[A-z]+>/gi, "" ).replace( / +/gi, " ").replace( /\n +/gi, "\n").replace( /\n\n+/gi, "\n").trim();
  if( mappedData.includes( "<h4>Drop information</h4>" ) ){
    mappedData = mappedData.substring( 0, mappedData.indexOf( "<h4>Drop information</h4>" ) - 1 );
  }

  let extractedData = {
    itemTypes: [],
    hasBuilds: false,
    requiredDlc: null,
    craftRequirement: "0",
    builds: {}
  };

  if( mappedData.includes( "Obtainable items:" ) ){
    const obtainableItemsSearchString = "Obtainable items:";
    let obtainableItems = mappedData.substring( mappedData.indexOf( obtainableItemsSearchString  ) + obtainableItemsSearchString.length ).trim();
    mappedData = mappedData.substring( 0, mappedData.indexOf( obtainableItemsSearchString ) - 1 );
    extractedData.itemTypes = obtainableItems.replace( /\*/gi, "" ).split( "\n")
  }

  let extractors = {
    "Name": "name",
    "Type": "type",
    "Location": "location",
    "Requires DLC": "requiredDlc",
    "Traits needed to craft": "craftRequirement"
  };

  mappedData.split( "\n" ).forEach( dataPoint => {
    if( dataPoint.includes( ": " ) ){
      let extractorName = dataPoint.substring( 0, dataPoint.indexOf( ": ") );
      if( extractors[extractorName] ){
        extractedData[extractors[extractorName]] = dataPoint.substring( extractorName.length + 2 );
      }
    }
  });

  let auxData = $(".global-container > .row > .col > .row:nth-child( 3 ) > div > h4" );
  let auxList = [];
  for( let i = 0; i < auxData.length; i++ ){
    auxList.push( $(auxData.get(i)).html().trim().toLowerCase() );
  }

  if( auxList.includes( "builds" ) ){
    extractedData.hasBuilds = true;
    let builds = $(".global-container > .row > .col > .row:nth-child( 3 ) > div > div.table-responsive > table > tbody > tr > td > a" );
    for( let i = 0; i < builds.length; i++ ){
      extractedData.builds[$(builds.get(i)).attr( "href" )] = $(builds.get(i)).html();
    }
  }

  extractedData["craftRequirement"] = parseInt( extractedData["craftRequirement"] );

  return extractedData;
  //List of builds//
}


runSets();