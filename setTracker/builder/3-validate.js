const setList = require( "./generate-list.json" );
const builds = require( "./builds.json" );

let setBuilds = new Set();

for( let i = 0; i < setList.length; i++ ){
  Object.keys( setList[i].builds ).forEach( build => {
    setBuilds.add( build );
  });
}

const noSets = [];
for( let item of setBuilds ){
  if( !builds[item] ){
    noSets.push( item );
  }
}

if( noSets.length > 0 ){
  console.log( "Not build data found for the following builds" );
  noSets.forEach( build => console.log( build ) );
}
else{
  console.log( "All build data is accepted" );
}