// Functions allow to write data in smart contractss
import { BigNumber, ethers } from "ethers";
import toast from "react-hot-toast";
import {
  contract,
  tokenContract,
  ERC20,
  toEth,
  TOKEN_ICO_CONTRACT,
} from "./constants";

const STAKING_DAPP_ADDRESS = process.env.NEXT_PUBLIC_STAKING_DAPP;
const DEPOSIT_TOKEN = process.env.NEXT_PUBLIC_DEPOSIT_TOKEN;
const REWARD_TOKEN = process.env.NEXT_PUBLIC_REWARD_TOKEN;
const TOKEN_LOGO = process.env.NEXT_PUBLIC_TOKEN_LOGO;

const notifySuccess = (message) => {
  toast.success(message, {
    duration: 4000,
    position: "top-right",
  });
};
const notifyError = (message) => {
  toast.error(message, {
    duration: 4000,
    position: "top-right",
  });
};

function CONVERT_TIMESTAMP_TO_READABLE(timestamp) {
  const date = new Date(timestamp * 1000);
  const readableTime = date.toLocaleString("en-US", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  });

  return readableTime;
}
