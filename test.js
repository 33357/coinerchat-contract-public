function a(all){
    let _all=0;
    for(let i=0;i<12*4;i++){
        _all+=all
        all=all*0.95
    }
    return _all;
}


console.log(a(1))