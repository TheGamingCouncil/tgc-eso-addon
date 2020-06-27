function getPages(){
  let rows = $(".container > .row > .col > .row:nth-child(2) > div > .row");
  let output = [];

  for( let i = 0; i < rows.length; i++ ){
    let row = rows[i];
    let title = $("> .col-md-6 > h4", row ).html();
    let href = $("> .col-md-6 > a", row).attr( "href" );
    output.push( `"${title}": "${href}"`);
  }

  console.log( output.join( ",\n" ) );
}

//https://eso-sets.com/search/advanced