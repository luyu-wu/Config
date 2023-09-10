use std::io;
use rand::Rng;
use std::cmp::Ordering;

fn main() {
    println!("Guess the number!");
    let secret_number = rand::thread_rng().gen_range(1..=100);
    // println!("The secret number is: {secret_number}");

    loop {
        println!("Please input your guess.");
        let mut guess = String::new();
        io::stdin()
        .read_line(&mut guess)
        .expect("Failed to read line");
        println!("You guessed: {guess}");
        
        let guess: u32 = guess.trim().parse().expect("Please type a number!");
        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Too small!"),
            Ordering::Greater => println!("Too big!"),
            Ordering::Equal => {
                println!("You win!");
                break; // loop loops until break, alternatives are for and while
            }
        }
    }


    // OPERATORS

    // Addition
    let _sum = 5 + 10; // _ implies something? 
    // subtraction
    let _difference = 95.5 - 4.3;
    // multiplication
    let _product = 4 * 30;
    // division
    let _quotient = 56.7 / 32.2;
    let _truncated = -5 / 3; // Results in -1
    // remainder
    let _remainder = 43 % 5;

    // COMPOUND TYPES
    let _tup: (i32, f64, u8) = (500, 6.4, 1); //may be different types within a tuple

    let _a = [1, 2, 3, 4, 5]; // Must all be same type
    let _b: [i32; 5] = [1, 2, 3, 4, 5]; // Declarative
    let _c = [3; 5]; // Same as [3,3,3,3,3]
    another_function(55,'g');

    let mut condition = false; // true
    let number = if condition { 5 } else { 6 };    

    if number < 5 {
        println!("condition was true");
    } else if number % 5 == 0 {
        println!("Number divisible by 5");
    } else{
        println!("None of the conditions were met ");
    }

    while condition == false {
        condition = true // set condition to true past if the condition is false XD, just testing While loop
    }
}

fn another_function(value:u32,label:char) {
    println!("The value given is: {value}{label}");
}