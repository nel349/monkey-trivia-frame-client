"use client";

import React, { useCallback, useEffect, useRef, useState } from "react";
import dynamic from "next/dynamic";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Bars3Icon, BugAntIcon } from "@heroicons/react/24/outline";
import { FaucetButton } from "~~/components/scaffold-eth";
import { useOutsideClick } from "~~/hooks/scaffold-eth";

type HeaderMenuLink = {
  label: string;
  href: string;
  icon?: React.ReactNode;
};

export const menuLinks: HeaderMenuLink[] = [
  {
    label: "Home",
    href: "/",
  },
  {
    label: "Debug Contracts",
    href: "/debug",
    icon: <BugAntIcon className="h-4 w-4" />,
  },
];

export const HeaderMenuLinks = () => {
  const pathname = usePathname();

  return (
    <>
      {menuLinks.map(({ label, href, icon }) => {
        const isActive = pathname === href;
        return (
          <li key={href}>
            <Link
              href={href}
              passHref
              className={`${
                isActive ? "bg-secondary shadow-md" : ""
              } hover:bg-secondary hover:shadow-md focus:!bg-secondary active:!text-neutral py-1.5 px-3 text-sm rounded-full gap-2 grid grid-flow-col`}
            >
              {icon}
              <span>{label}</span>
            </Link>
          </li>
        );
      })}
    </>
  );
};

// const sdk = new CoinbaseWalletSDK({
//   appName: "Monkey Trivia",
//   appLogoUrl: "https://bafkreiamixpftrzntr2mxskev2vc5s7wnokr3hzhi3cz2pyh42p6n6zgv4.ipfs.nftstorage.link",
//   appChainIds: [CHAIN_ID()],
// });

// const provider = sdk.makeWeb3Provider();

const CoinbaseCreateWalletButton = dynamic(
  () => import("monkey-trivia-ui-components").then(mod => mod.CoinbaseCreateWalletButton),
  { ssr: false },
);
/**
 * Site header
 */
export const Header = () => {
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const [provider, setProvider] = useState<any>(null);
  const burgerMenuRef = useRef<HTMLDivElement>(null);
  useOutsideClick(
    burgerMenuRef,
    useCallback(() => setIsDrawerOpen(false), []),
  );

  useEffect(() => {
    if (typeof window !== "undefined") {
      const { CoinbaseWalletSDK } = require("@coinbase/wallet-sdk");
      const { CHAIN_ID } = require("~~/services/CoinbaseServiceConfigs");

      const sdk = new CoinbaseWalletSDK({
        appName: "Monkey Trivia",
        appLogoUrl: "https://bafkreiamixpftrzntr2mxskev2vc5s7wnokr3hzhi3cz2pyh42p6n6zgv4.ipfs.nftstorage.link",
        appChainIds: [CHAIN_ID()],
      });

      setProvider(sdk.makeWeb3Provider());
    }
  }, []);

  return (
    <div className="sticky lg:static top-0 navbar bg-base-100 min-h-0 flex-shrink-0 justify-between z-20 shadow-md shadow-secondary px-0 sm:px-2">
      <div className="navbar-start w-auto lg:w-1/2">
        <div className="lg:hidden dropdown" ref={burgerMenuRef}>
          <label
            tabIndex={0}
            className={`ml-1 btn btn-ghost ${isDrawerOpen ? "hover:bg-secondary" : "hover:bg-transparent"}`}
            onClick={() => {
              setIsDrawerOpen(prevIsOpenState => !prevIsOpenState);
            }}
          >
            <Bars3Icon className="h-1/2" />
          </label>
          {isDrawerOpen && (
            <ul
              tabIndex={0}
              className="menu menu-compact dropdown-content mt-3 p-2 shadow bg-base-100 rounded-box w-52"
              onClick={() => {
                setIsDrawerOpen(false);
              }}
            >
              <HeaderMenuLinks />
            </ul>
          )}
        </div>
        <Link href="/" passHref className="hidden lg:flex items-center gap-2 ml-4 mr-6 shrink-0">
          <div className="flex relative w-10 h-10">
            <Image alt="SE2 logo" className="cursor-pointer" fill src="/logo.svg" />
          </div>
          <div className="flex flex-col">
            <span className="font-bold leading-tight">Scaffold-ETH</span>
            <span className="text-xs">Ethereum dev stack</span>
          </div>
        </Link>
        <ul className="hidden lg:flex lg:flex-nowrap menu menu-horizontal px-1 gap-2">
          <HeaderMenuLinks />
        </ul>
      </div>
      <div className="navbar-end flex-grow mr-4">
        <CoinbaseCreateWalletButton
          handleSuccess={(address: string) => {
            console.log("success: ", address);
          }}
          handleError={(error: Error) => {
            console.log("error: ", error);
          }}
          provider={provider}
          fontSize="1rem"
        />
        <FaucetButton />
      </div>
    </div>
  );
};
