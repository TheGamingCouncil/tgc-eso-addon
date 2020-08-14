const setList = require( "./generate-list.json" );
const builds = require( "./builds.json" );
const fs = require( "fs" );

function breakLocation( location ){
  return location.split( "," ).map( location => location.trim() );
}

function buildTypes( builds ){
  return "nil"
}

function setToLua( set ){

  return `["${set.name}"] = {
    ["isTrash"] = ${!set.hasBuilds},
    ["type"] = "${set.type}",
    ["locations"] = { "${breakLocation(set.location).join('", "')}" },
    ["items"] = { "${set.itemTypes.join('", "')}" },
    ["buildTypes"] = ${buildTypes( set.builds )}
  }`;
}

fs.writeFileSync( "../setDatabase.lua", `TGC.setDb = {
  ${setList.map( set => setToLua( set )).join( ",\n  " )}
}` );