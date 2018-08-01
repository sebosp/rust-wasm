#![feature(use_extern_macros)]
extern crate wasm_bindgen;
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
extern {
    fn alert(s: &str);
}

#[wasm_bindgen]
pub fn greet(name: &str) {
    alert(&format!("Hello, {}!", name));
}
#[no_mangle]
pub extern fn add_one(a: u32) -> u32 {
  a + 1
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn it_adds_one() {
        assert_eq!(add_one(1), 2);
    }
}
