const map = require( "./pull.json" );
const http = require( "https" );
const jsdom = require("jsdom");

const site = "https://eso-sets.com";
let sets = Object.keys( map );

async function runSets(){
  //for( let i = 0; i < 10; i++ ){
    await runSingleSet( sets[0], map[sets[5]] );
  //}
  
}

async function runSingleSet( setName, setUrl ){
  let result = await getSet( setUrl );
  let setData = parseData( result );
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
  console.log( mappedData );


  let auxData = $(".global-container > .row > .col > .row:nth-child( 3 ) > div > h4" );
  let auxList = [];
  for( let i = 0; i < auxData.length; i++ ){
    auxList.push( $(auxData.get(i)).html().trim().toLowerCase() );
  }
  if( auxList.includes( "builds" ) ){
    console.log( "Builds: Yes" );
  }
  else{
    console.log( "Builds: No" );
  }
  //List of builds//
}


runSets();