const setList = require( "./generate-list.json" );
const builds = require( "./builds.json" );
const fs = require( "fs" );

function breakLocation( location ){
  return location.split( "," ).map( location => location.trim() );
}

function makeBuild( buildData ){
  return `{
        ["name"] = "${buildData.name}",
        ["environment"] = TGC.enums.environment.${buildData.use ? buildData.use.toLowerCase() : "any"},
        ["class"] = TGC.enums.class.${buildData.class || "any"},
        ["role"] = TGC.enums.role.${buildData.type || "any"},
        ["equipmentList"] = {}
      }`;
}

function makeGuide( guideData ){
    return `{
        ["name"] = "${guideData.name}",
        ["environment"] = TGC.enums.environment.${guideData.use ? guideData.use.toLowerCase() : "any"},
        ["class"] = TGC.enums.class.${guideData.class || "any"},
        ["role"] = TGC.enums.role.${guideData.type || "any"}
      }`;
}

function buildGuideData( unfilteredSetBuilds ){
  const setBuilds = Object.keys( unfilteredSetBuilds ).filter( buildUrl => builds[buildUrl].guide );
  if( setBuilds.length > 0 ){ 
    return `{\n      ${setBuilds.map( buildLink => makeGuide( builds[buildLink] ) ).join( ', ' ) }\n    }`;
  }
  else{
    return "{}";
  }
}

function buildSetBuilds( unfilteredSetBuilds ){
  const setBuilds = Object.keys( unfilteredSetBuilds ).filter( buildUrl => !builds[buildUrl].guide );
  if( setBuilds.length > 0 ){ 
    return `{\n      ${setBuilds.map( buildLink => makeBuild( builds[buildLink] ) ).join( ', ' ) }\n    }`;
  }
  else{
    return "{}";
  }
}

function setToLua( set ){

  return `["${set.name}"] = {
    ["isTrash"] = ${!set.hasBuilds},
    ["type"] = "${set.type}",
    ["locations"] = { "${breakLocation(set.location).join('", "')}" },
    ["items"] = { "${set.itemTypes.join('", "')}" },
    ["builds"] = ${buildSetBuilds( set.builds )},
    ["guides"] = ${buildGuideData( set.builds )}
  }`;
}

fs.writeFileSync( "../setDatabase.lua", `TGC.setDb = {
  ${setList.map( set => setToLua( set )).join( ",\n  " )}
}` );