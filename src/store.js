const KEY='dobromisto-v1',initial={joined:[],completed:[],activity:[],read:[],name:'Софія',companion:'leaf',decor:['flower'],custom:''};
export function load(){try{return {...initial,...JSON.parse(localStorage.getItem(KEY)||'{}')}}catch{return {...initial}}}
export function save(s){localStorage.setItem(KEY,JSON.stringify(s));return s}
export function reset(){localStorage.removeItem(KEY);return {...initial}}
