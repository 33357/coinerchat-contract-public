function a(all){
    let _all=0;
    for(let i=0;i<12;i++){
        _all+=all
        all=all*0.9
    }
    return _all;
}


console.log(a(1))