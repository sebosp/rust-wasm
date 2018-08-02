#![feature(use_extern_macros)]
extern crate wasm_bindgen;
use wasm_bindgen::prelude::*;

#[repr(u8)]
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Cell {
  Dead = 0,
  Alive = 1,
}

#[wasm_bindgen]
pub struct Universe {
  width: u32,
  height: u32,
  cells: Vec<Cell>,
}

impl Universe {
  fn get_index(&self, row: u32, column: u32) -> usize {
    (row * self.width + column) as usize
  }
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
  #[test]
  fn it_gets_index() {
    let uni = Universe {
      width: 4,
      height: 4,
      cells: vec![
        Cell::Dead,Cell::Dead,Cell::Dead,Cell::Dead,
        Cell::Dead,Cell::Dead,Cell::Dead,Cell::Dead,
        Cell::Dead,Cell::Dead,Cell::Dead,Cell::Dead,
        Cell::Dead,Cell::Dead,Cell::Dead,Cell::Dead,
      ],
    };
    assert_eq!(uni.get_index(0,0), 0);
    assert_eq!(uni.get_index(1,2), 6);
    assert_eq!(uni.get_index(2,2), 10);
    assert_eq!(uni.get_index(3,3), 15);
  }
}
